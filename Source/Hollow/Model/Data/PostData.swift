//
//  PostData.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/22.
//  Copyright © 2021 treehollow. All rights reserved.
//

import UIKit

/// Data wrapper representing a single post.
struct PostData: Identifiable, Codable {
    // Identifiable protocol
    var id: Int { return postId }
    
    var attention: Bool
    var deleted: Bool
    var likeNumber: Int
    var permissions: [PostPermissionType]
    var postId: Int
    var replyNumber: Int
    var timestamp: Date
    var tag: String?
    var text: String
    /// Image wrapper for actual image.
    ///
    /// Set `nil` when there is no image to display, and set `hollowImage.image` to `nil` when the actual image is still loading.
    var hollowImage: HollowImage?
    var vote: VoteData?
    var comments: [CommentData]
    
    var loadingError: String?
    
    // To avoid scanning the text over and over when the
    // text does not has components that needed to be
    // rendered as hyperlink, set the variable when initialize
    // comment data, and check them to decide whether to call
    // the methods to scan the text.
    var hasURL = false
    var hasCitedNumbers = false
    var renderHighlight: Bool { hasURL || hasCitedNumbers }
}

typealias CitedPostData = PostData

/// Wrapper to use when initializing a view for a post.
struct PostDataWrapper: Identifiable {
    // Identifiable protocol
    var id: Int { post.id }
    
    var post: PostData
    /// use `citedPostID` to get citedPostID
    var citedPostID: Int? {
        let citedPid = self.post.text.findCitedPostID()
        return citedPid == self.post.postId ? nil : citedPid
    }
    var citedPost: PostData?
}

extension PostDataWrapper {
    static func templatePost(for postId: Int) -> PostDataWrapper {
        let post = PostData(attention: false, deleted: false, likeNumber: 0, permissions: [], postId: postId, replyNumber: 0, timestamp: Date(), tag: nil, text: "", hollowImage: nil, vote: nil, comments: [], loadingError: nil)
        return PostDataWrapper(post: post, citedPost: nil)
    }
}
