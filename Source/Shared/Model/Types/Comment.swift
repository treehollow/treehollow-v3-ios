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
    /// postID
    var pid: Int
    var tag: String?
    var text: String?
    /// unix timestamp
    var timestamp: Int
    /// comment ID
    var replyTo: Int
    var isDz: Bool
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

extension Comment {
    /// Convert comment to commentData without image
    /// - Returns: CommentData
    func toCommentData() -> CommentData {
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
        var text = self.text
        while text?.first == "\n" {
            text?.removeFirst()
        }
        while text?.last == "\n" {
            text?.removeLast()
        }
        
        let hash = AvatarGenerator.hash(postId: pid, name: isDz ? "" : name)
        
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

        return CommentData(
            commentId: cid,
            deleted: deleted,
            name: name,
            permissions: permissions,
            postId: pid,
            tag: tag,
            text: text ?? "",
            date: Date(timeIntervalSince1970: TimeInterval(timestamp)),
            isDz: isDz,
            replyTo: replyTo,
            image: image,
            hasURL: (text?.links().count ?? 0) > 0,
            hasCitedNumbers: (text?.citations().count ?? 0) > 0,
            hash: hash,
            colorIndex: AvatarGenerator.colorIndex(hash: hash),
            abbreviation: abbreviation
        )
    }
}
