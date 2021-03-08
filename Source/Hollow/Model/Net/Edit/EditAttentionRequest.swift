//
//  EditAttentionRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation
import Alamofire

struct EditAttentionRequestConfiguration {
    var apiRoot: [String]
    var token: String
    /// Post id.
    var postId: Int
    /// `false` for cancel attention, `true` otherwise
    var switchToAttention: Bool
}

struct EditAttentionRequestResult: DefaultRequestResult {
    var code: Int
    var msg: String?
    /// The post data after editing attention
    var data: Post?
}

typealias EditAttentionRequestResultData = Post

struct EditAttentionRequest: DefaultRequest {
    typealias Configuration = EditAttentionRequestConfiguration
    typealias Result = EditAttentionRequestResult
    typealias ResultData = EditAttentionRequestResultData
    typealias Error = DefaultRequestError
    
    var configuration: EditAttentionRequestConfiguration
    
    init(configuration: EditAttentionRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (EditAttentionRequestResultData?, DefaultRequestError?) -> Void) {
        let urlPath = "v3/edit/attention" + Constants.URLConstant.urlSuffix
        
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]
        
        let parameters: [String : Encodable] = [
            "pid" : self.configuration.postId,
            "switch": self.configuration.switchToAttention ? 1 : 0,
        ]
        performRequest(
            urlBase: self.configuration.apiRoot,
            urlPath: urlPath,
            parameters: parameters,
            headers: headers,
            method: .post,
            transformer: {
                $0.data
            },
            completion: completion)
    }
}
