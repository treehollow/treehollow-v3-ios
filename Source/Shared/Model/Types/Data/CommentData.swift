//
//  CommentData.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/22.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

/// Data wrapper representing a single comment.
struct CommentData: Identifiable, Codable {
    // Identifiable protocol
    var id: Int { commentId }
    
    var commentId: Int
    var deleted: Bool
    var name: String
    var permissions: [PostPermissionType]
    var postId: Int
    var tag: String?
    var text: String
    var date: Date
    var isDz: Bool
    var replyTo: Int
    var image: HollowImage?
    
    var url: [String]
    var citedNumbers: [Int]
    var renderHighlight: Bool { !url.isEmpty || !citedNumbers.isEmpty }
    
    // Data used in avatar
    var showAvatar: Bool
    var showAvatarWhenReversed: Bool
    var hash: Int
    var colorIndex: Int
    var abbreviation: String
    
    // Additional replying to comment info
    var replyToCommentInfo: ReplyToCommentInfo?
    
    mutating func updateHashAndColor() {
        hash = AvatarGenerator.hash(postId: postId, name: name)
        colorIndex = AvatarGenerator.colorIndex(hash: hash)
    }
}

extension CommentData {
    struct ReplyToCommentInfo: Codable {
        var name: String
        var text: String
        var hasImage: Bool
    }
}
