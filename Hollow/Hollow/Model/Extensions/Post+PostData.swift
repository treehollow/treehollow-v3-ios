//
//  Post+PostData.swift
//  Hollow
//
//  Created by aliceinhollow on 2/20/21.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

extension Post {
    func toPostData(comments: [CommentData]) -> PostData {
        // precess post image
        var image: HollowImage? = nil
        if let imageurl = self.url, let imageMetadata = self.imageMetadata,
           let w = imageMetadata.w, let h = imageMetadata.h {
            image = HollowImage(placeholder: (width: w, height: h), image: nil, imageURL: imageurl)
        }
        
        return PostData(
            attention: self.attention,
            deleted: self.deleted,
            likeNumber: self.likenum,
            permissions: self.permissions,
            postId: self.pid,
            replyNumber: self.reply,
            tag: self.tag,
            text: self.text,
            hollowImage: image,
            vote: self.vote?.toVoteData(),
            comments: comments)
    }
}
