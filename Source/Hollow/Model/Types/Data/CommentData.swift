//
//  CommentData.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/22.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import HollowCore

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
    
    var attributedString: AttributedString
    
    // Data used in avatar
    var showAvatar: Bool
    var showAvatarWhenReversed: Bool
    var hash: Int
    var colorIndex: Int
    var abbreviation: String
    
    // Additional replying to comment info
    var replyToCommentInfo: ReplyToCommentInfo?
    
    mutating func updateHashAndColor() {
#if !WIDGET
        hash = AvatarGenerator.hash(postId: postId, name: name)
        colorIndex = AvatarGenerator.colorIndex(hash: hash)
#endif
    }
}

extension CommentData {
    struct ReplyToCommentInfo: Codable {
        var name: String
        var text: String
        var hasImage: Bool
    }
}

extension Comment {
    func toCommentData(showAvatar: Bool, showAvatarWhenReversed: Bool) -> CommentData {
        var image: HollowImage? = nil
        if let imageMetadata = self.imageMetadata, let imageURL = self.url,
           let w = imageMetadata.w, let h = imageMetadata.h {
            image = HollowImage(
                placeholder: (
                    width: w,
                    height: h
                ),
                image: nil,
                imageURL: imageURL)
        }
        var text = self.text ?? ""
        while text.first == "\n" {
            text.removeFirst()
        }
        while text.last == "\n" {
            text.removeLast()
        }
        
#if !WIDGET
        let hash = AvatarGenerator.hash(postId: pid, name: isDz ? "" : name)
#else
        let hash = 0
#endif
        
        let components = name.split(separator: " ")
        var abbreviation = isDz ? name : ""
        if !isDz {
            for component in components {
                if Int(component) != nil {
                    abbreviation = String(component)
                    break
                }
                abbreviation += component.first == nil ? "" : String(component.first!)
            }
        }
        
#if !WIDGET
        let attributedString = text.attributedForCitationAndLink()
        let colorIndex = AvatarGenerator.colorIndex(hash: hash)
#else
        let attributedString = AttributedString()
        let colorIndex = 0
#endif

        return CommentData(
            commentId: cid,
            deleted: deleted,
            name: name,
            permissions: permissions,
            postId: pid,
            tag: tag,
            text: text,
            date: Date(timeIntervalSince1970: TimeInterval(timestamp)),
            isDz: isDz,
            replyTo: replyTo,
            image: image,
            attributedString: attributedString,
            showAvatar: showAvatar,
            showAvatarWhenReversed: showAvatarWhenReversed,
            hash: hash,
            colorIndex: colorIndex,
            abbreviation: abbreviation
        )

    }
}

extension Array where Element == Comment {
    func toCommentData() -> [CommentData] {
        var commentData = [CommentData]()
        for index in self.indices {
            if index == 0 {
                commentData.append(
                    self[index].toCommentData(
                        showAvatar: true,
                        showAvatarWhenReversed: self.count <= 1 ? true : self[index].name != self[index + 1].name
                    )
                )
            } else if index == self.count - 1 {
                commentData.append(
                    self[index].toCommentData(
                        showAvatar: self.count <= 1 ? true : self[index].name != self[index - 1].name,
                        showAvatarWhenReversed: true
                    )
                )
            } else {
                commentData.append(self[index].toCommentData(showAvatar: self[index].name != self[index - 1].name, showAvatarWhenReversed: self[index].name != self[index + 1].name))
            }
            
        }
        
        return commentData
    }
}
