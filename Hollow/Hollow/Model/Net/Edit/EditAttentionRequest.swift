//
//  EditAttentionRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation

struct EditAttentionRequestConfiguration {
    /// Post id.
    var postId: Int
    /// `false` for cancel attention, `true` otherwise
    var switchToAttention: Bool
}

struct EditAttentionRequestResult {
    enum EditAttentionRequestResultType: Int {
        case success = 0
    }
    
    var type: EditAttentionRequestResultType
    /// The post data after editing attention
    var data: Post
}
