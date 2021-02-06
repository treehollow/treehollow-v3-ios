//
//  SearchRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation

struct SearchRequestConfiguration {
    var token: String
    var keywords: [String]
    var page: Int
    var beforeTimestamp: Int?
    var includeComment: Bool?
}

/// The result type is `PostListRequestResult`
typealias SearchRequestResult = PostListRequestResult
