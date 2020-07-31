//
//  ViewController.swift
//  AuthenticationManager
//
//  Created by slobodan-ristic on 07/30/2020.
//  Copyright (c) 2020 slobodan-ristic. All rights reserved.
//

import UIKit
import AuthenticationManager

class ViewController: UIViewController {
	
	private enum AuthenticationState {
		case loggedIn
		case loggedOut
	}
	
	@IBOutlet weak var buttonLogin: UIButton!
	@IBOutlet weak var viewState: UIView!
	@IBOutlet weak var labelFaceID: UILabel!
	
	// MARK: - Properties

	private let authenticationManager: AuthenticationManageable = AuthenticationManager()
	
	private var biometricType: BiometricType?
	
	private var state = AuthenticationState.loggedOut {
        didSet {
            buttonLogin.isHighlighted = state == .loggedIn
            viewState.backgroundColor = state == .loggedIn ? .green : .red
            labelFaceID.isHidden = (state == .loggedIn) || (biometricType != .faceID)
        }
    }
	
	// MARK: - Lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
       
		switch authenticationManager.biometricsType(with: .biometricsAndPasscode) {
		case .success(let biometricType):
			self.biometricType = biometricType
		case .failure(let error):
			print(error)
		}
		
		state = .loggedOut
    }
	
	@IBAction func buttonLoginTapped(_ sender: UIButton) {
		if state == .loggedIn {
			state = .loggedOut
		} else {
			let reason = "Log in to your account"
			let localizedCancelTitle = "Enter Username/Password"
			let authenticationOptions = MTAuthenticationPresentOptions(authenticationType: .biometricsAndPasscode, reason: reason, cancelTitle: localizedCancelTitle, fallBackTitle: nil)
			authenticationManager.presentAuthenticationToUser(with: authenticationOptions) { [weak self] result in
				switch result {
				case .success:
					self?.state = .loggedIn
				case .failure(let error):
					print(error)
				}
			}
		}
	}

}

