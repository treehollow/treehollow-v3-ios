//
//  ReportCommentRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation

struct ReportCommentRequestConfiguration {
    var commentId: Int
    var type: PostPermissionType
    var reason: String
}

enum ReportCommentRequestResultType: Int {
    case success = 0
}
