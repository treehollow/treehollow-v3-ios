//
//  Post.swift
//  Hollow
//
//  Created by aliceinhollow on 11/2/2021.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import UIKit

/// **Deprecated! Don't use this to judge type**
enum PostType: String, Codable {
    case text = "text"
    case image = "image"
    case vote = "vote"
}

/// PostPermissions
enum PostPermissionType: String, Codable, CaseIterable {
    case report = "report"
    case fold = "fold"
    case setTag = "set_tag"
    case delete = "delete"
    case undeleteUnban = "undelete_unban"
    case deleteBan = "delete_ban"
    case unban = "unban"
}

/// ImageMetadata
struct ImageMetadata: Codable {
    var w: CGFloat
    var h: CGFloat
}

/// Post for request result, see `http-api doc`
struct Post: Codable {
    var attention: Bool
    var deleted: Bool
    var likenum: Int
    var permissions: [PostPermissionType]
    /// postId
    var pid: Int
    var reply: Int
    var tag: String?
    var text: String
    var timestamp: Int
    /// deprecated!
    var type: PostType?
    /// updateTimestamp
    var updatedAt: Int
    /// `url` entry in backend API,imageURL ,this name will be deprecated
    var url: String?
    var imageMetadata: ImageMetadata?
    var vote: Vote?
}

/// Vote for result
struct Vote: Codable {
    var voted: String
    var voteData: [String: Int]
}

