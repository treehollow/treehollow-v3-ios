//
//  LoginRequest.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/18.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Alamofire
import HollowCore

struct LoginRequestConfiguration {
    var email: String
    var password: String
    let deviceType = 2
    let deviceInfo = Constants.Application.deviceInfo
    var deviceToken: String?
    var apiRoot: String
}

struct LoginRequest: DefaultResultRequestAdaptor {
    typealias R = HollowCore.LoginRequest
    typealias Configuration = LoginRequestConfiguration
    typealias FinalResult = HollowCore.LoginRequest.ResultData

    init(configuration: LoginRequest.Configuration) {
        self.configuration = configuration
    }
    
    var configuration: LoginRequest.Configuration
    
    func transformConfiguration(_ configuration: LoginRequestConfiguration) -> R.Configuration {
        return .init(apiRoot: configuration.apiRoot, email: configuration.email, password: configuration.password, deviceInfo: configuration.deviceInfo, deviceToken: configuration.deviceToken)
    }
}
