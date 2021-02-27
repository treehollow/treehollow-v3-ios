//
//  CommentData.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/22.
//  Copyright © 2021 treehollow. All rights reserved.
//

import UIKit

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
    /// **will be deprecated**
    var type: CommentType {
        get {
            if self.image != nil { return .image}
            else { return .text }
        }
    }
    var image: HollowImage?
}
