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
        if let imageMetadata = self.imageMetadata, let imageURL = self.url {
            image = HollowImage(
                placeholder: (
                    width: imageMetadata.w,
                    height: imageMetadata.h
                ),
                image: nil,
                imageURL: imageURL)
        }
        return CommentData(
            commentId: self.cid,
            deleted: self.deleted,
            name: self.name,
            permissions: self.permissions,
            postId: self.postId,
            tags: self.tags ?? [String](),
            text: self.text ?? "",
            image: image
        )
    }
}
