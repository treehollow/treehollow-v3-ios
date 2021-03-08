//
//  ReportCommentRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation
import Alamofire

struct ReportCommentRequestConfiguration {
    var apiRoot: [String]
    var token: String
    var commentId: Int
    var type: PostPermissionType
    var reason: String
}

typealias ReportCommentRequestResult = ReportRequestGroupResult

typealias ReportCommentRequestResultData = ReportCommentRequestResult

struct ReportCommentRequest: DefaultRequest {
    typealias Configuration = ReportCommentRequestConfiguration
    typealias Result = ReportCommentRequestResult
    typealias ResultData = ReportCommentRequestResultData
    typealias Error = DefaultRequestError
    var configuration: ReportCommentRequestConfiguration
    
    init(configuration: ReportCommentRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (ReportCommentRequestResultData?, DefaultRequestError?) -> Void) {
        let urlPath = "v3/edit/report/comment" + Constants.URLConstant.urlSuffix
        
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]
        
        let parameters: [String : Encodable] = [
            "id" : self.configuration.commentId,
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
