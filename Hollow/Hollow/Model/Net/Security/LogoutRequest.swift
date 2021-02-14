//
//  LogoutRequest.swift
//  Hollow
//
//  Created by aliceinhollow on 6/2/2021.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Alamofire

struct LogoutRequestConfiguration {
    var token: String
    var apiRoot: [String]
}

struct LogoutRequestResult: DefaultRequestResult {
    var code: Int
    var msg: String?
}

enum LogoutRequestResultData: Int {
    case success = 0
}

/// logout request same as devicetermination
struct LogoutRequest: DefaultRequest {
    typealias Configuration = LogoutRequestConfiguration
    typealias Result = LogoutRequestResult
    typealias ResultData = LogoutRequestResultData
    typealias Error = DefaultRequestError
    
    var configuration: LogoutRequestConfiguration
    
    init(configuration: LogoutRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (LogoutRequestResultData?, DefaultRequestError?) -> Void) {
        let urlPath = "v3/security/logout" + Constants.URLConstant.urlSuffix
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]
        performRequest(
            urlBase: self.configuration.apiRoot,
            urlPath: urlPath,
            // Empty parameter to satisfy generic type constrain.
            parameters: [String : Int](),
            headers: headers,
            method: .post,
            resultToResultData: { result in LogoutRequestResultData(rawValue: result.code) },
            completion: completion
        )
    }
}

