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
    var imageBaseURL: [String]
    var token: String
    var postId: Int
    /// when don't need comments, only need main post, set `needComments` to false
    var includeComments: Bool
    /// when dont't need cited post, set to false
    var includeCitedPost: Bool
    /// set true when need image
    var includeImage: Bool
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
            "include_comment" : configuration.includeComments
        ]
        
        if let oldupdated = PostCache().getTimestamp(postId: configuration.postId) {
            parameters["old_updated_at"] = oldupdated
        }
        
        let resultToResultData: (Result) -> ResultData? = { result in
            var postWrapper: PostDataWrapper
            
            if result.code == 1 {
                // use cached result
                // if return cache hit, then post must be in cache
                postWrapper = PostDataWrapper(
                    post: PostCache().getPost(postId: configuration.postId)!,
                    citedPost: nil
                )
            } else {
                // get new result
                guard let post = result.post else { return nil }
                let postData = post.toPostData(comments: [CommentData]() )
                // postdetail don't need cited post
                postWrapper = PostDataWrapper(post: postData, citedPost: nil)
                // return postWrapper without image, comment and cited post
                completion(postWrapper, nil)
                
                // cache without image, comment and cited post
                PostCache().updateTimestamp(postId: configuration.postId, timestamp: post.updatedAt)
                // force unwrap postWrapper
                PostCache().updatePost(postId: configuration.postId, postdata: postWrapper.post)
            }
            
            // load comments if needed
            if configuration.includeComments && postWrapper.post.comments.count < postWrapper.post.replyNumber {
                if let comments = result.data {
                    postWrapper.post.comments = comments.map { $0.toCommentData() }
                    completion(postWrapper, nil)
                    PostCache().updatePost(postId: configuration.postId, postdata: postWrapper.post)
                } else {
                    // no comment data, start a new request
                    let commentRequest =
                        PostDetailRequest(configuration:
                                            PostDetailRequestConfiguration(
                                                apiRoot: configuration.apiRoot,
                                                imageBaseURL: configuration.imageBaseURL,
                                                token: configuration.token,
                                                postId: postWrapper.post.id,
                                                includeComments: true,
                                                includeCitedPost: false,
                                                includeImage: false))
                    commentRequest.performRequest { (postData, error) in
                        if let comments = postData?.post.comments {
                            postWrapper.post.comments = comments
                            completion(postWrapper, nil)
                            PostCache().updatePost(postId: configuration.postId, postdata: postWrapper.post)
                        }
                    }
                }
            }
            
            // load citedPost if needed
            if configuration.includeCitedPost && postWrapper.citedPost == nil && postWrapper.citedPostID != postWrapper.post.postId {
                if let citedPid = postWrapper.post.text.findCitedPostID() {
                    let citedPostRequest =
                        PostDetailRequest(configuration:
                                            PostDetailRequestConfiguration(
                                                apiRoot: configuration.apiRoot,
                                                imageBaseURL: configuration.imageBaseURL,
                                                token: configuration.token,
                                                postId: citedPid,
                                                includeComments: false,
                                                includeCitedPost: false,
                                                includeImage: false))
                    citedPostRequest.performRequest { (postData, error) in
                        if let _ = error {
                            return
                        }
                        if let postData = postData {
                            postWrapper.citedPost = postData.post
                            completion(postWrapper, nil)
                            PostCache().updatePost(postId: configuration.postId, postdata: postWrapper.post)
                        }
                    }
                }
                
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
