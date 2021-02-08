//
//  Constants.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/3.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

struct Constants {
    struct Application {
        static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
    struct HollowConfig {
        static let thuConfigURL = "https://cdn.jsdelivr.net/gh/treehollow/thuhole-config@master/config.txt"
        static let pkuConfigURL = ""
    }

    struct URLConstant {
        static let urlSuffix = "?v=v\(Constants.Application.appVersion)&device=2"
    }
}
