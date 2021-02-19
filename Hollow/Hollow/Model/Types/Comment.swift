//
//  Comment.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation

/// deprecated! dont use this to judge
enum CommentType: String, Codable {
    case text = "text"
    case image = "image"
}

/// Comment used for result
struct Comment: Codable {
    /// comment ID
    var cid: Int
    var deleted: Bool
    var name: String
    var permissions: [PostPermissionType]
    var postId: Int
    var tags: [String]?
    var text: String?
    /// unix timestamp
    var timestamp: Int
    /// comment ID
    var replyTo: Int
    // deprecated
    var type: CommentType {
        get {
            if self.url != nil { return .image }
            else { return .text }
        }
    }
    /// image url
    var url: String?
    var imageMetadata: ImageMetadata?
}
