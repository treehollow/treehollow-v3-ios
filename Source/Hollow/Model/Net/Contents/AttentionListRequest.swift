//
//  AttentionListRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation
import Alamofire

typealias AttentionListRequestConfiguration = PostListRequestConfiguration

typealias AttentionListRequestResult = PostListRequestResult

typealias AttentionListRequestResultData = [PostDataWrapper]

struct AttentionListRequest: DefaultRequest {
    typealias Configuration = AttentionListRequestConfiguration
    typealias Result = AttentionListRequestResult
    typealias ResultData = AttentionListRequestResultData
    typealias Error = DefaultRequestError
    var configuration: AttentionListRequestConfiguration
    
    init(configuration: AttentionListRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (AttentionListRequestResultData?, DefaultRequestError?) -> Void) {
        let urlPath = "v3/contents/post/attentions" + Constants.Net.urlSuffix
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]
        let parameters: [String : Encodable] = [
            "page" : configuration.page
        ]
        
        let transformer: (PostListRequestResult) -> AttentionListRequestResultData? = { result in
            guard let resultData = result.data else { return nil }
            var postWrappers = [PostDataWrapper]()
            postWrappers = resultData.map{ post in
                
                // process comments of current post
                
                var commentData = [CommentData]()
                if let comments = result.comments, let commentsOfPost = comments[post.pid.string]{
                    if let comments = commentsOfPost {
                        commentData = comments.map{ $0.toCommentData() }
                    }
                }
                
                return PostDataWrapper(post: post.toPostData(comments: commentData))
            }
            return postWrappers
        }
        
        performRequest(
            urlBase: self.configuration.apiRoot,
            urlPath: urlPath,
            parameters: parameters,
            headers: headers,
            method: .get,
            transformer: transformer,
            completion: completion
        )
    }
    
}
