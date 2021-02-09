//
//  LoginRequest.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/18.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Alamofire
import UIKit

struct LoginRequestConfiguration {
    var email: String
    var password: String
    let deviceType = 2
    let deviceInfo = UIDevice.current.name + ", iOS " + UIDevice.current.systemVersion
    // TODO: Device token
    var deviceToken: String
    var apiRoot: String
}

struct LoginRequestResult: DefaultRequestResult {
    var code: Int
    var token: String?
    var uuid: UUID?
    var msg: String?
}

struct LoginRequestResultData {
    var token: String
    var uuid: UUID
}

struct LoginRequest: DefaultRequest {
    
    typealias Configuration = LoginRequestConfiguration
    typealias Result = LoginRequestResult
    typealias ResultData = LoginRequestResultData
    typealias Error = DefaultRequestError
    
    var configuration: LoginRequestConfiguration
    
    init(configuration: LoginRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (ResultData?, Error?) -> Void)
    {
        let parameters =
            [
                "email": self.configuration.email,
                "password_hashed": self.configuration.password.sha256().sha256(),
                "device_type": self.configuration.deviceType.string,
                "device_info": self.configuration.deviceInfo,
                "ios_device_token": self.configuration.deviceToken,
            ]
        let urlPath =
            self.configuration.apiRoot + "v3/security/login/login" + Constants.URLConstant.urlSuffix
        performRequest(
            urlPath: urlPath,
            parameters: parameters,
            method: .post,
            resultToResultData: { result in
                guard let token = result.token, let uuid = result.uuid else { return nil }
                return LoginRequestResultData(token: token, uuid: uuid)
            },
            completion: completion
        )
    }
}
