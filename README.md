# AuthenticationManager

[![CI Status](https://img.shields.io/travis/slobodan-ristic/AuthenticationManager.svg?style=flat)](https://travis-ci.org/slobodan-ristic/AuthenticationManager)
[![Version](https://img.shields.io/cocoapods/v/AuthenticationManager.svg?style=flat)](https://cocoapods.org/pods/AuthenticationManager)
[![License](https://img.shields.io/cocoapods/l/AuthenticationManager.svg?style=flat)](https://cocoapods.org/pods/AuthenticationManager)
[![Platform](https://img.shields.io/cocoapods/p/AuthenticationManager.svg?style=flat)](https://cocoapods.org/pods/AuthenticationManager)

AuthenticationManager is a manager with which you can easily and simply determine whether the device supports biometrics (and if supported, which type of biometrics is available).

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 10.0+
- xCode 11.0+
- Swift 5.0+

## Installation

#### CocoaPods

```ruby
pod 'AuthenticationManager'
```

## Usage

Create instance of manager with protocol type 'AuthenticationManageable'
```ruby
let authenticationManager: AuthenticationManageable = AuthenticationManager()
```

With object you can use 2 functions:
- first 'biometricsType', with which check whether device support touch ID or face ID. Function return error if authentication isn't available.
```ruby
authenticationManager.biometricsType
```

## Author

slobodan-ristic, slobodan.ristic@swiftylabs.io

## License

AuthenticationManager is available under the MIT license. See the LICENSE file for more info.
