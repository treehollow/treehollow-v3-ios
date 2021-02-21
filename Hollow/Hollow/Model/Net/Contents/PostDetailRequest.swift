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
            
            var postWrapper: PostDataWrapper?
            
            if result.code == 1 {
                // use cached result
                // if return cache hit, then post must be in cache
                postWrapper = PostDataWrapper(
                    post: PostCache().getPost(postId: configuration.postId)!,
                    citedPost: nil
                )
            } else {
                // get new result
                if let post = result.post {
                    let postData = post.toPostData(comments: [CommentData]() )
                    // postdetail don't need cited post
                    postWrapper = PostDataWrapper(post: postData, citedPost: nil)
                    // return postWrapper without image, comment and cited post
                    completion(postWrapper,nil)
                    
                    // cache without image, comment and cited post
                    PostCache().updateTimestamp(postId: configuration.postId, timestamp: post.updatedAt)
                    // force unwrap postWrapper
                    PostCache().updatePost(postId: configuration.postId, postdata: postWrapper!.post)
                }
            }
            
            // load comments if needed
            if configuration.includeComments && postWrapper!.post.comments.isEmpty {
                if let comments = result.data {
                    postWrapper!.post.comments = comments.map { $0.toCommentData() }
                    completion(postWrapper, nil)
                    PostCache().updatePost(postId: configuration.postId, postdata: postWrapper!.post)
                } else {
                    // no comment data, start a new request
                    let commentRequest =
                        PostDetailRequest(configuration:
                                            PostDetailRequestConfiguration(
                                                apiRoot: configuration.apiRoot,
                                                imageBaseURL: configuration.imageBaseURL,
                                                token: configuration.token,
                                                postId: postWrapper!.post.id,
                                                includeComments: true,
                                                includeCitedPost: false,
                                                includeImage: false))
                    commentRequest.performRequest { (postData, error) in
                        if let comments = postData?.post.comments {
                            postWrapper!.post.comments = comments
                            completion(postWrapper, nil)
                            PostCache().updatePost(postId: configuration.postId, postdata: postWrapper!.post)
                        }
                    }
                }
            }
            
            // load citedPost if needed
            if configuration.includeCitedPost && (postWrapper!.citedPost == nil) {
                if let citedPid = postWrapper?.post.text.findCitedPostID() {
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
                        if let postData = postData {
                            postWrapper!.citedPost = postData.post
                            completion(postWrapper, nil)
                            PostCache().updatePost(postId: configuration.postId, postdata: postWrapper!.post)
                        }
                    }
                }
            }
            
            // load image if needed
            if configuration.includeImage {
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
                                        ))
                                    }
                                }
                            )
                        }
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
                       completion: completion
        )
    }
}
