//
//  PostData.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/22.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

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
    
    // Pre fetched cited post id
    var citedPostId: Int?
    
    var attributedString: AttributedString
//    var url: [String]
//    var citedNumbers: [Int]
//    var renderHighlight: Bool { !url.isEmpty || !citedNumbers.isEmpty }

    // Color data used in avatar
    var hash: Int
    var colorIndex: Int
    
    mutating func updateHashAndColor() {
        hash = AvatarGenerator.hash(postId: postId, name: "")
        colorIndex = AvatarGenerator.colorIndex(hash: hash)
    }
}

/// Wrapper to use when initializing a view for a post.
struct PostDataWrapper: Identifiable {
    // Identifiable protocol
    var id: Int { post.id }
    
    var post: PostData
    /// use `citedPostID` to get citedPostID
    var citedPostID: Int? {
        let citedPid = self.post.citedPostId
        return citedPid == self.post.postId ? nil : citedPid
    }
    var citedPost: PostData?
}

extension PostDataWrapper {
    static func templatePost(for postId: Int) -> PostDataWrapper {
        let hash = AvatarGenerator.hash(postId: postId, name: "")
        let colorIndex = AvatarGenerator.colorIndex(hash: hash)
        let post = PostData(
            attention: false,
            deleted: false,
            likeNumber: 0,
            permissions: [],
            postId: postId,
            replyNumber: 0,
            timestamp: Date(),
            tag: nil, text: "",
            hollowImage: nil,
            vote: nil,
            comments: [],
            loadingError: nil,
            attributedString: .init(),
//            url: [],
//            citedNumbers: [],
            hash: hash,
            colorIndex: colorIndex
        )
        return PostDataWrapper(post: post, citedPost: nil)
    }
}
