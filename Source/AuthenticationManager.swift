//
//  AuthenticationManager.swift
//  erstembanking
//
//  Created by Slobodan on 03/07/2020.
//  Copyright © 2020 Semos. All rights reserved.
//

import Foundation
import LocalAuthentication

public protocol AuthenticationManageable {
	func biometricsType(with type: AuthenticationType) -> Result<BiometricType, Error>
	func presentAuthenticationToUser(with options: MTAuthenticationPresentOptions, completion: @escaping (Result<BiometricType, Error>) -> () )
}

public enum BiometricType {
	case touchID
	case faceID
}

enum AuthenticationError: Error {
	case appCancel
	case systemCancel
	case userCancel
	case biometryLockout
	case biometryNotAvailable
	case biometryNotEnrolled
	case authenticationFailed
	case invalidContext
	case notInteractive
	case passcodeNotSet
	case userFallback
	case notSupported
	case defaultError(Error)
}

public enum AuthenticationType {
	case biometricsAndPasscode
	case biometrics
	
	var policy: LAPolicy {
		switch self {
		case .biometricsAndPasscode:
			return .deviceOwnerAuthentication
		case .biometrics:
			return .deviceOwnerAuthenticationWithBiometrics
		}
	}
}

public struct MTAuthenticationPresentOptions {
	
	// MARK: - Properties
	
	var authenticationType: AuthenticationType
	var reason: String
	var cancelTitle: String?
	var fallBackTitle: String?
	
	// MARK: - Initialization
	
	public init(authenticationType: AuthenticationType, reason: String, cancelTitle: String?, fallBackTitle: String?) {
		self.authenticationType = authenticationType
		self.reason = reason
		self.cancelTitle = cancelTitle
		self.fallBackTitle = fallBackTitle
	}
	
}

public final class AuthenticationManager {
	
	// MARK: - Properties
	
	private let context = LAContext()
	private var error: NSError?
	
	// MARK: - Initialization
	
	public init() {}
	
	// MARK: - Private methods
	
	private func isAuthenticationAvailable(with type: AuthenticationType) -> Result<Void, Error> {
		if context.canEvaluatePolicy(type.policy, error: &error), let error = error {
			return .failure(error)
		}
		return .success(())
	}
	
	private func checkError(with error: Error) -> AuthenticationError {
		guard #available(iOS 11.0, *) else { return .notSupported }
		switch error._code {
		case LAError.appCancel.rawValue:
			return .appCancel
		case LAError.systemCancel.rawValue:
			return .systemCancel
		case LAError.userCancel.rawValue:
			return .userCancel
		case LAError.biometryLockout.rawValue:
			return .biometryLockout
		case LAError.biometryNotAvailable.rawValue:
			return .biometryNotAvailable
		case LAError.biometryNotEnrolled.rawValue:
			return .biometryNotEnrolled
		case LAError.authenticationFailed.rawValue:
			return .authenticationFailed
		case LAError.invalidContext.rawValue:
			return .invalidContext
		case LAError.notInteractive.rawValue:
			return .notInteractive
		case LAError.passcodeNotSet.rawValue:
			return .passcodeNotSet
		case LAError.userFallback.rawValue:
			return .userFallback
		default:
			return .defaultError(error)
		}
	}
	
	private func setLocalizedTitles(with options: MTAuthenticationPresentOptions) {
		if #available(iOS 10.0, *) {
			context.localizedCancelTitle = options.cancelTitle
		}
		context.localizedFallbackTitle = options.fallBackTitle
	}
	
	private func requestAuthentication(with options: MTAuthenticationPresentOptions, completion: @escaping (Result<BiometricType, Error>) -> () ) {
		setLocalizedTitles(with: options)
		context.evaluatePolicy(options.authenticationType.policy, localizedReason: options.reason) { [weak self] success, error in
			guard let self = self else { return }
			DispatchQueue.main.async {
				
				guard success else {
					if let error = error {
						completion(.failure(self.checkError(with: error)))
					}
					return
				}
				
				guard #available(iOS 11.0, *) else {
					completion(.success(.touchID))
					return
				}
				
				switch self.context.biometryType {
				case .touchID:
					completion(.success(.touchID))
				case .faceID:
					completion(.success(.faceID))
				default:
					completion(.failure(AuthenticationError.notSupported))
				}
				
			}
		}
	}
	
}

// MARK: - AuthenticationManageable

extension AuthenticationManager: AuthenticationManageable {
	
	public func presentAuthenticationToUser(with options: MTAuthenticationPresentOptions, completion: @escaping (Result<BiometricType, Error>) -> ()) {
		switch isAuthenticationAvailable(with: options.authenticationType) {
		case .success:
			requestAuthentication(with: options, completion: completion)
		case .failure(let error):
			completion(.failure(checkError(with: error)))
		}
	}
	
	public func biometricsType(with type: AuthenticationType) -> Result<BiometricType, Error> {
		switch isAuthenticationAvailable(with: type) {
		case .success:
			guard #available(iOS 11.0, *) else {
				return .success(.touchID)
			}
			switch context.biometryType {
			case .touchID:
				return .success(.touchID)
			case .faceID:
				return .success(.faceID)
			default:
				return .failure(AuthenticationError.notSupported)
			}
		case .failure(let error):
			return .failure(checkError(with: error))
		}
	}
		
}
