//
//  ReportPostRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation
import Alamofire

struct ReportPostRequestConfiguration {
    var apiRoot: [String]
    var token: String
    var postId: Int
    var type: PostPermissionType
    // reason can't be empty
    var reason: String
}

typealias ReportPostRequestResult = ReportRequestGroupResult

typealias ReportPostRequestResultData = ReportPostRequestResult

struct ReportPostRequest: DefaultRequest {
    typealias Configuration = ReportPostRequestConfiguration
    typealias Result = ReportPostRequestResult
    typealias ResultData = ReportPostRequestResultData
    typealias Error = DefaultRequestError
    var configuration: ReportPostRequestConfiguration
    
    init(configuration: ReportPostRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (ReportPostRequestResultData?, DefaultRequestError?) -> Void) {
        let urlPath = "v3/edit/report/post" + Constants.Net.urlSuffix
        
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]
        
        let parameters: [String : Encodable] = [
            "id" : self.configuration.postId,
            "type": self.configuration.type.rawValue,
            "reason" : self.configuration.reason,
        ]
        performRequest(
            urlBase: self.configuration.apiRoot,
            urlPath: urlPath,
            parameters: parameters,
            headers: headers,
            method: .post,
            transformer: { $0 },
            completion: completion)
    }
    
}
