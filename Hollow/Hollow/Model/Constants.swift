//
//  Constants.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/3.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

struct Constants {
    struct HollowConfig {
        static let thuConfigURL = "https://cdn.jsdelivr.net/gh/treehollow/thuhole-config@master/config.txt"
        static let pkuConfigURL = ""
    }
    struct Register {
        static let passwordRegex = try! NSRegularExpression(pattern: "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[*.!@$%^&(){}[]:;<>,.?/~_+-=|\\]).{8,32}$")
    }
}
