//
//  SendVoteRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation

struct SendVoteRequestConfiguration {
    var option: String
    var postId: Int
}

typealias SendVoteRequestResult = SendVoteRequestResultType

enum SendVoteRequestResultType: Int {
    case success = 0
}
