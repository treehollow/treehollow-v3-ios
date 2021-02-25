//
//  SearchRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation
import Alamofire

struct SearchRequestConfiguration {
    var apiRoot: [String]
    var imageBaseURL: [String]
    var token: String
    var keywords: String
    var page: Int
    var beforeTimestamp: Int?
    var includeComment: Bool = true
}

/// The result type is `PostListRequestResult`

typealias SearchRequestResult = PostListRequestResult

typealias SearchRequestResultData = [PostDataWrapper]

struct SearchRequest: DefaultRequest {


    typealias Configuration = SearchRequestConfiguration
    typealias Result = PostListRequestResult
    typealias ResultData = SearchRequestResultData
    typealias Error = DefaultRequestError
    
    var configuration: SearchRequestConfiguration
    
    init(configuration: SearchRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (SearchRequestResultData?, DefaultRequestError?) -> Void) {
        let urlPath = "v3/contents/search" + Constants.URLConstant.urlSuffix
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]
        
        var parameters: [String : Encodable] = [
            "keywords" : configuration.keywords,
            "page" : configuration.page,
            "include_comment" : configuration.includeComment
        ]
        
        if let before = configuration.beforeTimestamp {
            parameters["before"] = before
        }
        
        let resultToResultData: (PostListRequestResult) -> SearchRequestResultData? = { result in
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
            resultToResultData: resultToResultData,
            completion: completion)
        
    }
    
}
