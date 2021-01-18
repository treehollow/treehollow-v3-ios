//
//  PostDetail.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation

struct PostDetailRequestConfiguration {
    var token: String
    var postId: Int
    /// if this param is given and there's no new comment, the return code would
    /// be 1 (`.successWithNoNewComment`), while comments and post would be none.
    var oldUpdateTimestamp: Int?
}

struct PostDetailRequestResult {
    enum ResultType: Int {
        case success = 0
        case successWithNoNewComment = 1
    }
    
    var type: ResultType
    var post: Post
    var comments: [Comment]
}
