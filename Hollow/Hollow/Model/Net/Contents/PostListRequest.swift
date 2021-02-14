//
//  Post.swift
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
    struct Data: Codable {
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
    }
    var code: Int
    var msg: String?
    var data: [Data]?
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
        performRequest(
            urlBase: self.configuration.apiRoot,
            urlPath: urlPath,
            parameters: parameters,
            headers: headers,
            method: .get,
            resultToResultData: { result in
                var postWrappers = [PostDataWrapper]()
                for post in result.data! {
                    // process votes
                    // process image
//                    var image: HollowImage? = nil
//                    if let imageURL = post.url, let imageMetaData = post.imageMetadata {
//                        image = HollowImage(placeholder: (width: imageMetaData.w, height: imageMetaData.h), image: nil)
//                        image?.setImageURL(imageURL)
//                    }
                    // process citedpost
                    
                    // process comments (<=3 per post)
                    
//                    postWrappers.append(
//                        PostDataWrapper(post: PostData(
//                            attention: post.attention,
//                            deleted: post.deleted,
//                            likeNumber: post.likenum,
//                            permissions: post.permissions,
//                            postId: post.pid,
//                            replyNumber: post.reply,
//                            tag: post.tag,
//                            text: post.text,
//                            // deprecated type
//                            type: post.type ?? .text,
//                            hollowImage: image,
//                            vote: vote,
//                            /// no comment here
//                            comments: [CommentData]()
//                        ), citedPost: CitedPostData(postId: 0, text: "testtext")))
                }
            return postWrappers
            },
            completion: completion)
    }
    
}
