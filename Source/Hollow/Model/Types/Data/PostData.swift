//
//  PostData.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/22.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import HollowCore

/// Data wrapper representing a single post.
struct PostData: Identifiable, Codable {
    // Identifiable protocol
    var id: Int { return postId }
    
    var attention: Bool
    var deleted: Bool
    var likeNumber: Int
    var permissions: [PostPermissionType]
    var postId: Int
    var replyNumber: Int
    var timestamp: Date
    var tag: String?
    var text: String
    /// Image wrapper for actual image.
    ///
    /// Set `nil` when there is no image to display, and set `hollowImage.image` to `nil` when the actual image is still loading.
    var hollowImage: HollowImage?
    var vote: VoteData?
    var comments: [CommentData]
    
    var loadingError: String?
    
    // Pre fetched cited post id
    var citedPostId: Int?
    
#if !WIDGET
    @available (iOS 15.0, *)
    var attributedString: AttributedString {
        return text.attributedForCitationAndLink(citationsRanges: rangesForCitation, linkRanges: rangesForLink)
    }
#endif

    var rangesForLink: [NSRange]
    var rangesForCitation: [NSRange]

    // Color data used in avatar
    var hash: Int
    var colorIndex: Int
    
    mutating func updateHashAndColor() {
        #if !WIDGET
        hash = AvatarGenerator.hash(postId: postId, name: "")
        colorIndex = AvatarGenerator.colorIndex(hash: hash)
        #endif
    }
}

/// Wrapper to use when initializing a view for a post.
struct PostDataWrapper: Identifiable {
    // Identifiable protocol
    var id: Int { post.id }
    
    var post: PostData
    /// use `citedPostID` to get citedPostID
    var citedPostID: Int? {
        let citedPid = self.post.citedPostId
        return citedPid == self.post.postId ? nil : citedPid
    }
    var citedPost: PostData?
}

extension PostWrapper {
    func toPostDataWrapper() -> PostDataWrapper {
        return PostDataWrapper(post: post.toPostData(comments: comments.toCommentData()))
    }
}

extension PostDataWrapper {
    static func templatePost(for postId: Int) -> PostDataWrapper {
#if !WIDGET
        let hash = AvatarGenerator.hash(postId: postId, name: "")
        let colorIndex = AvatarGenerator.colorIndex(hash: hash)
#else
        let hash = 0
        let colorIndex = 0
#endif
        let post = PostData(
            attention: false,
            deleted: false,
            likeNumber: 0,
            permissions: [],
            postId: postId,
            replyNumber: 0,
            timestamp: Date(),
            tag: nil, text: "",
            hollowImage: nil,
            vote: nil,
            comments: [],
            loadingError: nil,
            rangesForLink: [],
            rangesForCitation: [],
            hash: hash,
            colorIndex: colorIndex
        )
        return PostDataWrapper(post: post, citedPost: nil)
    }
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
        
#if !WIDGET
        let linkRanges = text.rangeForLink()
        let citationRanges = text.rangeForCitation()
        let hash = AvatarGenerator.hash(postId: pid, name: "")
        let colorIndex = AvatarGenerator.colorIndex(hash: hash)
        let citedPostId = text.findCitedPostID()
#else
        let linkRanges = [NSRange]()
        let citationRanges = [NSRange]()
        let hash = 0
        let colorIndex = 0
        let citedPostId: Int? = nil
#endif
        
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
            citedPostId: citedPostId,
            rangesForLink: linkRanges,
            rangesForCitation: citationRanges,
            hash: hash,
            colorIndex: colorIndex
        )
    }
}

