//
//  AccountCreationRequest.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import HollowCore

/// Configuraions for creating an account.
struct AccountCreationRequestConfiguration {
    /// User's email.
    var email: String
    /// store passwd
    var password: String
    /// Device type, 2 for iOS.
    let deviceType = 2
    /// Device information.
    let deviceInfo: String = Constants.Application.deviceInfo
    /// Email valid code, optional, but one of `oldToken` and `validCode` must be present.
    var validCode: String?
    // TODO: Device token for APNs
    var deviceToken: String?
    /// See `AccountCreationConfiguration`
    ///
    var apiRoot: String
}

struct AccountCreationRequest: DefaultResultRequestAdaptor {
    typealias R = HollowCore.AccountCreationRequest
    typealias Configuration = AccountCreationRequestConfiguration
    typealias FinalResult = HollowCore.AccountCreationRequest.ResultData

    init(configuration: AccountCreationRequest.Configuration) {
        self.configuration = configuration
    }
    
    var configuration: AccountCreationRequest.Configuration
    
    func transformConfiguration(_ configuration: AccountCreationRequestConfiguration) -> R.Configuration {
        return .init(apiRoot: configuration.apiRoot, email: configuration.email, password: configuration.password, deviceInfo: configuration.deviceInfo, deviceToken: configuration.deviceToken)
    }
}
