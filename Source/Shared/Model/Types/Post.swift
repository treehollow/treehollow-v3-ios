//
//  Post.swift
//  Hollow
//
//  Created by aliceinhollow on 11/2/2021.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

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

extension Post {
    func toPostData(comments: [CommentData]) -> PostData {
        // precess post image
        var image: HollowImage? = nil
        if let imageurl = self.url, let imageMetadata = self.imageMetadata,
           let w = imageMetadata.w, let h = imageMetadata.h {
            image = HollowImage(placeholder: (width: w, height: h), image: nil, imageURL: imageurl)
        }
        
        var text = self.text
        
        while text.first == "\n" {
            text.removeFirst()
        }
        while text.last == "\n" {
            text.removeLast()
        }
        
        // Process replying to comment info
        var comments = comments
        for index in comments.indices {
            if comments[index].replyTo != -1,
               let replyToComment = comments.first(where: { $0.commentId == comments[index].replyTo }) {
                comments[index].replyToCommentInfo = .init(name: replyToComment.name, text: replyToComment.text, hasImage: replyToComment.image != nil)
            }
        }
        
        let hash = AvatarGenerator.hash(postId: pid, name: "")
        return PostData(
            attention: attention,
            deleted: deleted,
            likeNumber: likenum,
            permissions: permissions,
            postId: pid,
            replyNumber: reply,
            timestamp: Date(timeIntervalSince1970: TimeInterval(self.timestamp)),
            tag: tag,
            text: text,
            hollowImage: image,
            vote: vote?.toVoteData(),
            comments: comments,
            citedPostId: text.findCitedPostID(), hasURL: text.links().count > 0,
            hasCitedNumbers: text.citations().count > 0,
            hash: hash,
            colorIndex: AvatarGenerator.colorIndex(hash: hash)
        )
    }
}
