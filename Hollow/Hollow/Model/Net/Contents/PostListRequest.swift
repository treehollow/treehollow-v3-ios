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
    var needImage: Bool
    var imageBaseURL: [String]
}

/// Result for PostListRequest
struct PostListRequestResult: DefaultRequestResult {
    struct PostsData: Codable {
        struct ImageMetadata: Codable {
            var w: CGFloat?
            var h: CGFloat?
        }
        var attention: Bool
        var deleted: Bool
        var likenum: Int
        var permissions: [PostPermissionType]
        var pid: Int
        var reply: Int
        var tag: String?
        var text: String
        var timestamp: Int
        var updatedAt: Int
        var url: String?
        var imageMetadata: ImageMetadata?
        var vote: Vote?
    }
    var code: Int
    var msg: String?
    var data: [PostsData]?
    var comments: [Int: [Comment]]?
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
        let parameters: [String : String] = [
            "page" : configuration.page.string
        ]
        
        let resultToResultData: (PostListRequestResult) -> PostListRequestResultData? = { result in
            var postWrappers = [PostDataWrapper]()
            guard let resultData = result.data else { return nil }
            for post in resultData {
                // process votes
                
                var votedata: VoteData? = nil
                
                if let vote = post.vote {
                    votedata = vote.toVoteData()
                }
                
                // process imageMetadata
                
                var image: HollowImage? = nil
                
                if let imageURL = post.url, let imageMetaData = post.imageMetadata,
                   let w = imageMetaData.w, let h = imageMetaData.h {
                    image = HollowImage(placeholder: (width: w, height: h), image: nil, imageURL: imageURL)
                }
                
                // process comments (<=3 per post)
                
                var commentData = [CommentData]()
                
                if let comments = result.comments, let commentToPost = comments[post.pid] {
                    commentData = commentToPost.map{ $0.toCommentData() }
                }
                
                postWrappers.append(
                    PostDataWrapper(
                        post: PostData(
                            attention: post.attention,
                            deleted: post.deleted,
                            likeNumber: post.likenum,
                            permissions: post.permissions,
                            postId: post.pid,
                            replyNumber: post.reply,
                            tag: post.tag,
                            text: post.text,
                            hollowImage: image,
                            vote: votedata,
                            comments: commentData
                        ),
                        citedPost: nil
                    )
                )
                
            }
            
            // no citedPost and image here
            completion(postWrappers,nil)
            // process citedPost
            
            // TODO: fill in citedPost
            
            // start loading image
            for index in postWrappers.indices {
                // image in post
                if let url = postWrappers[index].post.hollowImage?.imageURL {
                    ImageDownloader.downloadImage(
                        urlBase: self.configuration.imageBaseURL,
                        urlString: url,
                        imageCompletionHandler: { image in
                            if let image = image {
                                postWrappers[index].post.hollowImage?.setImage(image)
                                completion(postWrappers, nil)
                            } else {
                                // TODO: handle image fail
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
