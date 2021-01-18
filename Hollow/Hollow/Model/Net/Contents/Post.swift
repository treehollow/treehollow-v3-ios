//
//  Post.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation


enum PostType: String {
    case text = "text"
    case image = "image"
    case vote = "vote"
}

enum PostPermissionType: String {
    case report = "report"
    case fold = "fold"
    case setTag = "set_tag"
    case delete = "delete"
    case undeleteUnban = "undelete_unban"
    case deleteBan = "delete_ban"
    case unban = "unban"
}

struct Post {
    
    struct Vote {
        var voted: Bool
        var voteData: [(title: String, voteCount: Int)]
    }
    
    var attention: Bool
    var deleted: Bool
    var likeNumber: Int
    var permissions: [PostPermissionType]
    var postId: Int
    var replyNumber: Int
    // FIXME: tag or tags?
    var tag: String
    var text: String
    var timestamp: Int
    var type: PostType
    var updateTimestamp: Int
    /// `url` entry in backend API
    var imageURL: String?
    var imageMetadata: (width: Int, height: Int)?
    var vote: Vote?
}
