//
//  ReportPostRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation

struct ReportPostRequestConfiguration {
    var postId: Int
    var type: PostPermissionType
    var reason: String
}

enum ReportPostRequestResultType: Int {
    case success = 0
}
