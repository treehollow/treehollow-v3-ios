//
//  LoginRequest.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/18.
//  Copyright © 2021 treehollow. All rights reserved.
//

import UIKit

struct LoginRequestConfiguration {
    var email: String
    var hashedPassword: String
    let deviceType = 2
    let deviceInfo = UIDevice.current.name
    // TODO: Device token
}

struct LoginRequestResult {
    enum ResultType: Int {
        case success = 0
    }
    
    var type: ResultType
    var token: String
    var uuid: UUID
    var message: String?
}
