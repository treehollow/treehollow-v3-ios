//
//  Comment.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation

enum CommentType {
    case text, image
}

struct Comment {
    var commentId: Int
    var deleted: Bool
    var name: String
    var permissions: [PostPermissionType]
    var postId: Int
    // FIXME: Tag or tags
    var tags: [String]
    var text: String
    var timestamp: Int
    var type: CommentType
    var imageURL: String?
    var imageMetadata: (width: Int, height: Int)?
}
