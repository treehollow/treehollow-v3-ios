//
//  PostDetail.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation
import HollowCore

struct PostDetailRequestConfiguration {
    var apiRoot: String
    var token: String
    var postId: Int
    /// when don't need comments, only need main post, set `needComments` to false
    var includeComments: Bool
}

struct PostDetailRequest: RequestAdaptor {
    typealias R = HollowCore.PostDetailRequest
    typealias Configuration = PostDetailRequestConfiguration
    typealias FinalResult = PostDataWrapper
    
    var configuration: PostDetailRequestConfiguration
    
    init(configuration: PostDetailRequestConfiguration) {
        self.configuration = configuration
    }
    
    func transformConfiguration(_ configuration: PostDetailRequestConfiguration) -> HollowCore.PostDetailRequestConfiguration {
        let postCache = PostCache.shared
        var config = HollowCore.PostDetailRequestConfiguration(
            // FIXME: Auto switch
            apiRoot: configuration.apiRoot,
            token: configuration.token,
            postId: configuration.postId,
            includeComments: configuration.includeComments
        )
        
        if let oldUpdatedAt = postCache.getTimestamp(postId: configuration.postId),
           let postWrapper = postCache.getPost(postId: configuration.postId) {
            config.lastUpdateTimestamp = oldUpdatedAt
            config.cachedPost = postWrapper
        }
        
        return config
    }
    
    func transformResult(_ result: PostDetailRequestResultData) -> PostDataWrapper {
        let postCache = PostCache.shared
        
        var postWrapper: PostWrapper
        var postDataWrapper: PostDataWrapper
        
        switch result {
        case .cached(let data):
            postWrapper = data
        case .new(let data):
            postWrapper = data
        }
        
        if let cachedPost = postCache.getPost(postId: configuration.postId),
           cachedPost.post.updatedAt == postWrapper.post.updatedAt {
            var comments = cachedPost.comments.toCommentData()
            for index in comments.indices {
                comments[index].updateHashAndColor()
            }
            let postData = postWrapper.post.toPostData(comments: comments)
            postDataWrapper = PostDataWrapper(post: postData)
        } else {
            let comments = postWrapper.comments.toCommentData()
            let postData = postWrapper.post.toPostData(comments: comments)
            postDataWrapper = PostDataWrapper(post: postData)
            
            if configuration.includeComments {
                postCache.updatePost(postId: configuration.postId, postWrapper: postWrapper)
                postCache.updateTimestamp(postId: configuration.postId, timestamp: postWrapper.post.updatedAt)
            }
        }
        
        return postDataWrapper
    }
}
