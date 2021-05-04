//
//  UnregisterCheckEmailRequest.swift
//  Hollow
//
//  Created by liang2kl on 2021/5/1.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

struct UnregisterCheckEmailRequestConfiguration {
    var email: String
    var recaptchaToken: String?
    let recaptchaVersion = "v2"
    var apiRoot: [String]
}

struct UnregisterCheckEmailRequestResult: DefaultRequestResult {
    var code: Int
    var msg: String?
}

enum UnregisterCheckEmailRequestResultData: Int {
    case success = 1
    case needReCAPTCHA = 3
}

struct UnregisterCheckEmailRequest: DefaultRequest {
    typealias Configuration = UnregisterCheckEmailRequestConfiguration
    typealias Result = UnregisterCheckEmailRequestResult
    typealias ResultData = UnregisterCheckEmailRequestResultData
    typealias Error = DefaultRequestError
    
    var configuration: UnregisterCheckEmailRequestConfiguration
    
    init(configuration: UnregisterCheckEmailRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (UnregisterCheckEmailRequestResultData?, DefaultRequestError?) -> Void) {
        var parameters: [String : Any] = [
            "email" : configuration.email,
            "recaptcha_version" : configuration.recaptchaVersion
        ]
        
        if let token = configuration.recaptchaToken {
            parameters["recaptcha_token"] = token
        }
        
        let urlPath = "v3/security/login/check_email_unregister" + Constants.Net.urlSuffix
        
        performRequest(
            urlBase: configuration.apiRoot,
            urlPath: urlPath,
            parameters: parameters,
            method: .post,
            transformer: { result in
                guard result.code == 1 || result.code == 3 else { return nil }
                return ResultData(rawValue: result.code)
            },
            completion: completion
        )
    }
}
