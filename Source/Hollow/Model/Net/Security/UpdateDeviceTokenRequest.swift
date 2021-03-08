//
//  UpdateDeviceTokenRequest.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/17.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Alamofire

struct UpdateDeviceTokenRequestConfiguration {
    var deviceToken: Data
    var token: String
    var apiRoot: [String]
}

struct UpdateDeviceTokenRequestResult: DefaultRequestResult {
    var code: Int
    var msg: String?
}

struct UpdateDeviceTokenRequest: DefaultRequest {
    typealias Configuration = UpdateDeviceTokenRequestConfiguration
    typealias Result = UpdateDeviceTokenRequestResult
    typealias ResultData = Result
    typealias Error = DefaultRequestError

    var configuration: UpdateDeviceTokenRequestConfiguration
    
    init(configuration: UpdateDeviceTokenRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (UpdateDeviceTokenRequestResult?, DefaultRequestError?) -> Void) {
        let urlPath = "v3/security/update_ios_token" + Constants.URLConstant.urlSuffix
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]
        let parameters = [
            "ios_device_token": self.configuration.deviceToken.hexEncodedString()
        ]
        
        performRequest(
            urlBase: self.configuration.apiRoot,
            urlPath: urlPath,
            parameters: parameters,
            headers: headers,
            method: .post,
            transformer: { $0 },
            completion: completion
        )
    }
    
}
