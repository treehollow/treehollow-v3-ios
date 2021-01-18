//
//  Post.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import Foundation

// TODO: Add documentation when HTTP doc updates

struct PostListRequestConfiguration {
    var token: String
    var page: Int
}

struct PostListRequestResult {
    enum ResultType: Int {
        case success = 0
    }
    struct Configuration {
        var announcement: Bool
        var foldTags: [String]
        var imageBaseURL: String
        var imageBaseURLBak: String
        // FIXME: Missing iOS frontend version
    }
    
    var type: ResultType
    var configuration: Configuration?
    var count: Int
    var posts: [Post]
}
