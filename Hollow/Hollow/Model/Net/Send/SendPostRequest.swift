//
//  SendPostRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation

struct SendPostRequestConfiguration {
    var text: String
    var type: PostType
    var imageData: Data?
    var voteData: [String]?
    
    init?(text: String, type: PostType, imageData: Data?, voteData: [String]?) {
        if type == .image && imageData == nil { return nil }
        if type == .vote && voteData == nil { return nil }
        self.text = text
        self.type = type
        self.imageData = imageData
        self.voteData = voteData
    }
}

enum SendPostRequestResultType: Int {
    case success = 0
}
