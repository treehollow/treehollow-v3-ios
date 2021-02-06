//
//  SendCommentRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation

struct SendCommentRequestConfiguration {
    var text: String
    var type: CommentType
    var imageData: Data?
    /// Id of the post to be commented
    var postId: Int
    
    init?(text: String, type: CommentType, imageData: Data?, postId: Int) {
        if type == .image && imageData == nil { return nil }
        self.text = text
        self.type = type
        self.imageData = imageData
        self.postId = postId
    }
}

enum SendCommentRequestType: Int {
    case success = 0
}
