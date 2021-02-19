//
//  CommentData.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/22.
//  Copyright © 2021 treehollow. All rights reserved.
//

import UIKit

/// Data wrapper representing a single comment.
struct CommentData: Identifiable {
    // Identifiable protocol
    var id: Int { commentId }
    
    var commentId: Int
    var deleted: Bool
    var name: String
    var permissions: [PostPermissionType]
    var postId: Int
    var tags: [String]
    var text: String
    /// **will be deprecated**
    var type: CommentType {
        get {
            if self.image != nil { return .image}
            else { return .text }
        }
    }
    var image: HollowImage?
}
