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
    // deprecated
    // var type: CommentType
    var imageData: Data?
    /// Id of the post to be commented
    var postId: Int
    /// id of the comment this comment may reply to
    var replyToCid: Int?
}

struct SendCommentRequestResult: DefaultRequestResult {
    var code: Int
    var msg: String?
}

typealias SendCommentRequestResultData = SendCommentRequestResult

struct SendCommentRequest: DefaultRequest {
    typealias Configuration = SendCommentRequestConfiguration
    typealias Result = SendCommentRequestResult
    typealias ResultData = SendCommentRequestResultData
    typealias Error = DefaultRequestError
    var configuration: SendCommentRequestConfiguration
    
    init(configuration: SendCommentRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (SendCommentRequestResultData?, DefaultRequestError?) -> Void) {
        let urlPath = "v3/send/comment" + Constants.URLConstant.urlSuffix
        let hasImage = configuration.imageData != nil
        
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]

        var parameters: [String : Encodable] = [
            "text" : configuration.text,
            // type will be deprecated!
            "type" : hasImage ? "image" : "text",
            "pid": configuration.postId
        ]

        if let imageData = configuration.imageData {
            print(imageData.base64EncodedData().count)
            parameters["data"] = imageData.base64EncodedString()
        }
        
        if let replyToCid = self.configuration.replyToCid {
            parameters["reply_to_cid"] = replyToCid
        }
        
        performRequest(urlBase: self.configuration.apiRoot,
                       urlPath: urlPath,
                       parameters: parameters,
                       headers: headers,
                       method: .post,
                       resultToResultData: { $0 },
                       completion: completion)
    }
    
}
