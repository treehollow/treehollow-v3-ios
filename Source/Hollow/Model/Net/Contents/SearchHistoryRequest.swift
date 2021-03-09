//
//  SearchHistoryRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation
import Alamofire

/// The configuration
struct SearchHistoryRequestConfiguration {
    var apiRoot: [String]
    var token: String
}

struct SearchHistoryRequestResult: DefaultRequestResult {
    var code: Int
    var msg: String?
    var data: [String]?
}

/// history string list
typealias SearchHistoryRequestResultData = [String]

struct SearchHistoryRequest: DefaultRequest {
    typealias Configuration = SearchHistoryRequestConfiguration
    typealias Result = SearchHistoryRequestResult
    typealias ResultData = SearchHistoryRequestResultData
    typealias Error = DefaultRequestError
    var configuration: SearchHistoryRequestConfiguration
    
    init(configuration: SearchHistoryRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (SearchHistoryRequestResultData?, DefaultRequestError?) -> Void) {
        let urlPath = "v3/contents/search/get_search_history" + Constants.Net.urlSuffix
        
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]

        let parameters = [String : Encodable]()
        
        performRequest(
            urlBase: self.configuration.apiRoot,
            urlPath: urlPath,
            parameters: parameters,
            headers: headers,
            method: .post,
            transformer: { $0.data },
            completion: completion
        )
    }
}
