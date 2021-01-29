//
//  PostData.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/22.
//  Copyright © 2021 treehollow. All rights reserved.
//

import UIKit

/// Data wrapper representing a single post.
struct PostData: Identifiable {
    // Identifiable protocol
    var id: Int { return postId }
    
    /// Set it to `nil` when the user has tapped on the button but the request has not finished.
    var attention: Bool?
    var deleted: Bool
    var likeNumber: Int
    var permissions: [PostPermissionType]
    var postId: Int
    var replyNumber: Int
    var tag: String
    var text: String
    var type: PostType
    /// Image wrapper for actual image.
    ///
    /// Set `nil` when there is no image to display, and set `hollowImage.image` to `nil` then the actual image is still loading.
    var hollowImage: HollowImage?
    var vote: Post.Vote?
    var comments: [CommentData]
}