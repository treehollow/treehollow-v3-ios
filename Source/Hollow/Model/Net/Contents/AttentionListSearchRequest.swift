//
//  AttentionListSearchRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation
import Alamofire

struct AttentionListSearchRequestConfiguration {
    var apiRoot: [String]
    var imageBaseURL: [String]
    var token: String
    var keywords: String
    var page: Int
}

typealias AttentionListSearchRequestResult = SearchRequestResult

typealias AttentionListSearchRequestResultData = [PostDataWrapper]

struct AttentionListSearchRequest: DefaultRequest {

    typealias Configuration = AttentionListSearchRequestConfiguration
    typealias Result = AttentionListSearchRequestResult
    typealias ResultData = AttentionListSearchRequestResultData
    typealias Error = DefaultRequestError
    
    var configuration: AttentionListSearchRequestConfiguration
    
    init(configuration: AttentionListSearchRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (AttentionListSearchRequestResultData?, DefaultRequestError?) -> Void) {
        let urlPath = "v3/contents/search/attentions" + Constants.URLConstant.urlSuffix
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]
        
        let parameters: [String : Encodable] = [
            "keywords" : configuration.keywords,
            "page" : configuration.page,
        ]
        
        let transformer: (PostListRequestResult) -> SearchRequestResultData? = { result in
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
            urlBase: configuration.apiRoot,
            urlPath: urlPath,
            parameters: parameters,
            headers: headers,
            method: .get,
            transformer: transformer,
            completion: completion)
        
    }
    
}

