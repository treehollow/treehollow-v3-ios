//
//  Post.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import Foundation
import Alamofire
import UIKit

// TODO: Add documentation when HTTP doc updates

/// Configuration for PostListRequest
struct PostListRequestConfiguration {
    var apiRoot: String
    var token: String
    var page: Int
    var needImage: Bool
    var imageBaseURL: String
    var imageBaseURLbak: String
}

/// Result for PostListRequest
struct PostListRequestResult: DefaultRequestResult {
    var code: Int
    var msg: String?
    var data: [Post]
}

/// ResultData for PostListRequest
struct PostListRequestResultData {
    var hasImage: Bool
    var posts: [PostData]
}

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
        let urlPath = self.configuration.apiRoot + "v3/contents/post/list" + Constants.URLConstant.urlSuffix
        let parameters = [String: String]()
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]
        performRequest(
            urlPath: urlPath,
            parameters: parameters,
            headers: headers,
            method: .get,
            resultToResultData: {result in
                var posts = [PostData]()
                for post in result.data {
                    // process votes
                    var vote: VoteData? = nil
                    if let voteResult = post.vote {
                        vote = initVoteDataByVote(voteResult: voteResult)
                    }
                    var image: HollowImage? = nil
                    if let imageURL = post.url, let imageMetaData = post.imageMetadata {
                        image = HollowImage(placeholder: (width: CGFloat(imageMetaData.w), height: CGFloat(imageMetaData.h)), image: nil)
                        image?.setImageURL(imageURL)
                    }
                    posts.append(
                        PostData(
                            attention: post.attention,
                            deleted: post.deleted,
                            likeNumber: post.likenum,
                            permissions: post.permissions,
                            postId: post.pid,
                            replyNumber: post.reply,
                            tag: post.tag,
                            text: post.text,
                            type: post.type ?? .text,
                            hollowImage: image,
                            vote: vote,
                            /// no comment here
                            comments: [CommentData]()
                        )
                    )
                }
                if self.configuration.needImage {
                    // need image
                    completion(ResultData(hasImage: false, posts: posts),nil)
                    // load image here
                    for postData in posts {
                        if let image = postData.hollowImage {
                            // process image
                        }
                    }
                    return ResultData(hasImage: true, posts: posts)
                }
                else {
                    //don't need image
                    return ResultData(hasImage: false, posts: posts)
                }
            },
            completion: completion)
    }
    
}
