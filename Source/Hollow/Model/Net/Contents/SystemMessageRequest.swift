//
//  SystemMessageRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation
import Alamofire

/// The configuration parameter is the user token.
struct SystemMessageRequestConfiguration {
    var token: String
    var apiRoot: [String]
}

/// Wrapper for result of attempt to get system messages
struct SystemMessageRequestResult: DefaultRequestResult {
    var code: Int
    var msg: String?
    var result: [SystemMessage]?
}

typealias SystemMessageRequestResultData = [SystemMessage]

/// SystemMessageRequest same as default request
struct SystemMessageRequest: DefaultRequest {
    typealias Configuration = SystemMessageRequestConfiguration
    typealias Result = SystemMessageRequestResult
    typealias ResultData = SystemMessageRequestResultData
    typealias Error = DefaultRequestError
    var configuration: SystemMessageRequestConfiguration
    
    init(configuration: SystemMessageRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (SystemMessageRequestResultData?, DefaultRequestError?) -> Void) {
        let urlPath = "v3/contents/system_msg" + Constants.URLConstant.urlSuffix
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]
        performRequest(
            urlBase: self.configuration.apiRoot,
            urlPath: urlPath,
            headers: headers,
            method: .get,
            resultToResultData: { $0.result },
            completion: completion)
    }
    
}
