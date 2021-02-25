//
//  Comment+CommentData.swift
//  Hollow
//
//  Created by aliceinhollow on 2/19/21.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

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

        return CommentData(
            commentId: self.cid,
            deleted: self.deleted,
            name: self.name,
            permissions: self.permissions,
            postId: self.pid,
            tag: self.tag,
            text: text ?? "",
            date: Date(timeIntervalSince1970: TimeInterval(self.timestamp)),
            isDz: self.isDz,
            replyTo: self.replyTo,
            image: image
        )
    }
}
