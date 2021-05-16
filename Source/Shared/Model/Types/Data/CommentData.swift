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
    
    // To avoid scanning the text over and over when the
    // text does not has components that needed to be
    // rendered as hyperlink, set the variable when initialize
    // comment data, and check them to decide whether to call
    // the methods to scan the text.
    var hasURL = false
    var hasCitedNumbers = false
    var renderHighlight: Bool { hasURL || hasCitedNumbers }
    
    // Data used in avatar
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
