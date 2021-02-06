//
//  SetPushRequest.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/22.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

enum PushNotificationType: Int {
    case none = 0
    case likedOnly = 1
    case replyOnly = 2
    case all = 3
}

struct SetPushRequestConfiguration {
    var token: String
    var type: PushNotificationType
}

typealias SetPushRequestResult = SetPushRequestResultType

enum SetPushRequestResultType: Int {
    case success = 0
}
