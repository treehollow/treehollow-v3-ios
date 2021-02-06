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

enum PostPermissionType: String, CaseIterable {
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
        /// The option that the current user selected, `nil` if not voted.
        var votedOption: String?
        var voteData: [VoteData]
        struct VoteData: Identifiable {
            // Identifiable
            var id: String { self.title }
            
            var title: String
            var voteCount: Int
        }
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
