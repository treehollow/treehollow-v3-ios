//
//  PostDetail.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation
import Alamofire

struct PostDetailRequestConfiguration {
    var apiRoot: [String]
    var token: String
    var postId: Int
    /// when don't need comments, only need main post, set `needComments` to false
    var includeComments: Bool
}

struct PostDetailRequestResult: DefaultRequestResult {
    var code: Int
    var msg: String?
    var post: Post?
    var data: [Comment]?
}

typealias PostDetailRequestResultData = PostDataWrapper

struct PostDetailRequest: DefaultRequest {
    
    typealias Configuration = PostDetailRequestConfiguration
    typealias Result = PostDetailRequestResult
    typealias ResultData = PostDetailRequestResultData
    typealias Error = DefaultRequestError
    
    var configuration: PostDetailRequestConfiguration
    
    init(configuration: PostDetailRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (PostDetailRequestResultData?, DefaultRequestError?) -> Void) {
        let urlPath = "v3/contents/post/detail" + Constants.Net.urlSuffix
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]
        
        var parameters: [String : Encodable] = [
            "pid" : configuration.postId.string,
            "include_comment" : configuration.includeComments.int.string
        ]
        
        let postCache = PostCache()
        
        if let oldUpdated = postCache.getTimestamp(postId: configuration.postId),
           postCache.existPost(postId: configuration.postId) {
            parameters["old_updated_at"] = oldUpdated
        }
        
        let transformer: (Result) -> ResultData? = { result in
            var postWrapper: PostDataWrapper
            
            guard let post = result.post else { return nil }
            
            if result.code == 1, let cachedPost = postCache.getPost(postId: configuration.postId) {
                // The post has been cached and there's no update.
                
                // Update the color data in case of the change of the preset
                var comments = cachedPost.comments
                for index in comments.indices {
                    comments[index].updateHashAndColor()
                }
                // The only thing that is certain to remain unchanged is the comment data,
                // thus we need to integrate other part of the latest result.
                let postData = post.toPostData(comments: comments)
                postWrapper = PostDataWrapper(post: postData)
                
            } else {
                // The post has not been cached or there's update.
                
                let comments = result.data?.compactMap({ $0.toCommentData() }) ?? []
                let postData = post.toPostData(comments: comments)
                postWrapper = PostDataWrapper(post: postData)
                
                // Only update time stamp when requesting comments
                if configuration.includeComments {
                    postCache.updatePost(postId: configuration.postId, postdata: postWrapper.post)
                    postCache.updateTimestamp(postId: configuration.postId, timestamp: post.updatedAt)
                }
            }
            
            return postWrapper
        }
        
        performRequest(
            urlBase: configuration.apiRoot,
            urlPath: urlPath,
            parameters: parameters,
            headers: headers,
            method: .get,
            transformer: transformer,
            completion: completion
        )
    }
}
