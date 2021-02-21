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
    var imageBaseURL: [String]
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
            
            // return no citedPost and image here
            completion(postWrappers,nil)
            
            // process citedPost
            
            for index in postWrappers.indices {
                if let citedPid = postWrappers[index].post.text.findCitedPostID() {
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
                            postWrappers[index].citedPost = postData.post
                            completion(postWrappers, nil)
                        }
                    }
                }
            }
            
            // start loading image
            for index in postWrappers.indices {
                // image in post
                if let url = postWrappers[index].post.hollowImage?.imageURL {
                    ImageDownloader.downloadImage(
                        urlBase: self.configuration.imageBaseURL,
                        urlString: url,
                        imageCompletionHandler: { image in
                            if let image = image {
                                postWrappers[index].post.hollowImage?.image = image
                                completion(postWrappers, nil)
                            } else {
                                // report image loading fail
                                completion(postWrappers,.imageLoadingFail(postID: postWrappers[index].post.id))
                            }
                        }
                    )
                }
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
