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
        let urlPath = "v3/contents/post/detail" + Constants.URLConstant.urlSuffix
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]
        
        var parameters: [String : Encodable] = [
            "pid" : configuration.postId.string,
            "include_comment" : configuration.includeComments.int.string
        ]
        
        let postCache = PostCache()
        
        if let oldupdated = postCache.getTimestamp(postId: configuration.postId),
           postCache.existPost(postId: configuration.postId) {
            parameters["old_updated_at"] = oldupdated
        }
        
        let resultToResultData: (Result) -> ResultData? = { result in
            var postWrapper: PostDataWrapper
            if result.code == 1 {
                // use cached result
                // if return cache hit, then post must be in cache
                guard let postCache = postCache.getPost(postId: configuration.postId) else { return nil }
                postWrapper = PostDataWrapper(post: postCache)
                completion(postWrapper,nil)
            } else {
                // get new result
                guard let post = result.post else { return nil }
                var comments = [CommentData]()
                if let commentData = result.data {
                    comments = commentData.compactMap({ $0.toCommentData() })
                }
                let postData = post.toPostData(comments: comments)
                postWrapper = PostDataWrapper(post: postData)
                completion(postWrapper, nil)
                
                let postCache = PostCache()
                // cache without image, comment and cited post
                postCache.updateTimestamp(postId: configuration.postId, timestamp: post.updatedAt)
                postCache.updatePost(postId: configuration.postId, postdata: postWrapper.post)
            }
            
            return postWrapper
        }
        performRequest(urlBase: configuration.apiRoot,
                       urlPath: urlPath,
                       parameters: parameters,
                       headers: headers,
                       method: .get,
                       resultToResultData: resultToResultData,
                       completion: completion
        )
    }
}
