//
//  PublishedPostsMessageRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation

typealias PublishedPostsMessageRequestConfiguration = PostListRequestConfiguration

struct PublishedPostsMessageRequestResult {
    enum ResultType: Int {
        case success = 0
    }
    
    var type: ResultType
}
