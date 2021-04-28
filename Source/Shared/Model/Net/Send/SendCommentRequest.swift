//
//  SendCommentRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation
import Alamofire

struct SendCommentRequestConfiguration {
    var apiRoot: [String]
    var token: String
    
    var text: String
    var imageData: String?
    /// Id of the post to be commented
    var postId: Int
    var replyCommentId: Int?
}

struct SendCommentRequestResult: DefaultRequestResult {
    var code: Int
    var msg: String?
    var commentId: Int?
}

struct SendCommentRequest: DefaultRequest {
    typealias Configuration = SendCommentRequestConfiguration
    typealias Result = SendCommentRequestResult
    typealias ResultData = SendCommentRequestResult
    typealias Error = DefaultRequestError
    
    var configuration: SendCommentRequestConfiguration
    
    init(configuration: SendCommentRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (SendCommentRequestResult?, DefaultRequestError?) -> Void) {
        let urlPath = "v3/send/comment" + Constants.Net.urlSuffix
        let hasImage = configuration.imageData != nil
        
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]

        var parameters: [String : Encodable] = [
            "text" : configuration.text,
            "type" : hasImage ? "image" : "text",
            "pid" : configuration.postId,
        ]
        
        // Optionals are not allowed.
        if let imageData = configuration.imageData {
            parameters["data"] = imageData
        }
        
        if let replyToCommentId = configuration.replyCommentId {
            parameters["reply_to_cid"] = replyToCommentId
        }

        performRequest(
            urlBase: configuration.apiRoot,
            urlPath: urlPath,
            parameters: parameters,
            headers: headers,
            method: .post,
            transformer: { $0 },
            completion: completion
        )
    }
}