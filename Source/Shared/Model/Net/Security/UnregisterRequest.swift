//
//  UnregisterRequest.swift
//  Hollow
//
//  Created by liang2kl on 2021/5/1.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

struct UnregisterRequestConfiguration {
    var email: String
    var nonce: String
    var validCode: String
    var apiRoot: [String]
}

struct UnregisterRequestResult: DefaultRequestResult {
    var code: Int
    var msg: String?
}

struct UnregisterRequest: DefaultRequest {
    typealias Configuration = UnregisterRequestConfiguration
    typealias Result = UnregisterRequestResult
    typealias ResultData = Result
    typealias Error = DefaultRequestError
    
    var configuration: UnregisterRequestConfiguration
    
    init(configuration: UnregisterRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (UnregisterRequestResult?, DefaultRequestError?) -> Void) {
        let parameters: [String : Any] = [
            "email" : configuration.email,
            "nonce" : configuration.nonce,
            "valid_code" : configuration.validCode
        ]
        
        let urlPath = "v3/security/login/unregister" + Constants.Net.urlSuffix
        
        performRequest(
            urlBase: configuration.apiRoot,
            urlPath: urlPath,
            parameters: parameters,
            method: .post,
            transformer: { $0 },
            completion: completion
        )
    }
}
