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
    /// if this param is given and there's no new comment, the return code would
    /// be 1 (`.successWithNoNewComment`), while comments and post would be none.
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
            "pid" : configuration.postId
        ]
        
        if let oldupdated = PostCache().getTimestamp(postId: configuration.postId) {
            parameters["old_updated_at"] = oldupdated
        }
        
        let resultToResultData: (Result) -> ResultData? = { result in
            
            var postWrapper: PostDataWrapper? = nil
            
            if result.code == 1 { // use cached result
                // if return cache hit, then post must be in cache
                postWrapper = PostDataWrapper(post: PostCache().getPost(postId: configuration.postId)!, citedPost: nil)
            } else {
                // use new result
                if let post = result.post, let comments = result.data {
                    let postData = post.toPostData(comments: comments.map{ $0.toCommentData() })
                    // postdetail dont need cited post
                    postWrapper = PostDataWrapper(post: postData, citedPost: nil)
                    // return postWrapper without image and cited post
                    completion(postWrapper,nil)
                    // cache comments
                    PostCache().updateTimestamp(postId: configuration.postId, timestamp: post.updatedAt)
                    // force unwrap postWrapper
                    PostCache().updatePost(postId: configuration.postId, postdata: postWrapper!.post)
                }
            }
            
            // load post image
            
            if let url = postWrapper?.post.hollowImage?.imageURL {
                ImageDownloader.downloadImage(urlBase: configuration.imageBaseURL, urlString: url, imageCompletionHandler: {image in
                    if let image = image {
                        postWrapper?.post.hollowImage?.image = image
                        completion(postWrapper,nil)
                        PostCache().updatePost(postId: configuration.postId, postdata: postWrapper!.post)
                    } else {
                        completion(postWrapper,.imageLoadingFail(postID: (postWrapper?.post.postId)!))
                    }
                })
            }
            
            // load comments image
            
            if let comments = postWrapper?.post.comments {
                for index in comments.indices {
                    if let url = comments[index].image?.imageURL {
                        ImageDownloader.downloadImage(
                            urlBase: configuration.imageBaseURL,
                            urlString: url,
                            imageCompletionHandler: { image in
                                if let image = image {
                                    postWrapper?.post.comments[index].image?.image = image
                                    completion(postWrapper, nil)
                                    PostCache().updatePost(postId: configuration.postId, postdata: postWrapper!.post)
                                } else {
                                    // report image loading fail
                                    completion(postWrapper,.commentImageLoadingFail(
                                        postID: (postWrapper?.post.postId)!,
                                        commentID: comments[index].commentId
                                    )
                                    )
                                }
                            }
                        )
                    }
                }
            }
            return postWrapper
        }
        
        performRequest(urlBase: configuration.apiRoot,
                       urlPath: urlPath,
                       headers: headers,
                       method: .get,
                       resultToResultData: resultToResultData,
                       completion: completion)
    }
}
