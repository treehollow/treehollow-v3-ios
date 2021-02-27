//
//  PostListRequest.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import Foundation
import Alamofire
import UIKit

/// Configuration for PostListRequest
struct PostListRequestConfiguration {
    var apiRoot: [String]
    var token: String
    var page: Int
}

/// Result for PostListRequest
struct PostListRequestResult: DefaultRequestResult {
    var code: Int
    var msg: String?
    var data: [Post]?
    var comments: [String: [Comment]?]?
}

/// ResultData for PostListRequest
typealias PostListRequestResultData = [PostDataWrapper]

/// PostListRequest
struct PostListRequest: DefaultRequest {
    typealias Configuration = PostListRequestConfiguration
    typealias Result = PostListRequestResult
    typealias ResultData = PostListRequestResultData
    typealias Error = DefaultRequestError
    var configuration: PostListRequestConfiguration
    
    init(configuration: PostListRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (PostListRequestResultData?, DefaultRequestError?) -> Void) {
        let urlPath = "v3/contents/post/list" + Constants.URLConstant.urlSuffix
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]
        let parameters: [String : Encodable] = [
            "page" : configuration.page
        ]
        
        let resultToResultData: (PostListRequestResult) -> PostListRequestResultData? = { result in
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
            resultToResultData: resultToResultData,
            completion: completion
        )
    }
    
}