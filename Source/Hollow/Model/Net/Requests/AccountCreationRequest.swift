//
//  AccountCreationRequest.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import HollowCore
import Foundation

struct AccountCreationRequest: DefaultResultRequestAdaptor {
    typealias R = HollowCore.AccountCreationRequest
    struct Configuration {
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
        var deviceToken: Data?
        /// See `AccountCreationConfiguration`
        ///
        var apiRoot: String
    }
    typealias FinalResult = HollowCore.AccountCreationRequest.ResultData

    init(configuration: AccountCreationRequest.Configuration) {
        self.configuration = configuration
    }
    
    var configuration: AccountCreationRequest.Configuration
    
    func transformConfiguration(_ configuration: Configuration) -> R.Configuration {
        return .init(apiRoot: configuration.apiRoot, email: configuration.email, password: configuration.password, deviceInfo: configuration.deviceInfo, validCode: configuration.validCode, deviceToken: configuration.deviceToken)
    }
}
