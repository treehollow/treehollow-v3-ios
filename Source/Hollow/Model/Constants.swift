//
//  Constants.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/3.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

/// Shared constants.
///
/// The purpose of the nested enums is to provide namespaces.
enum Constants {
    enum Application {
        static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        static let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        static let appLocalizedName =
            Bundle.main.localizedInfoDictionary?["CFBundleName"] as? String ??
            Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
        static let requestedNotificationOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    }
    
    enum HollowConfig {
        static let thuConfigURL = "https://cdn.jsdelivr.net/gh/treehollow/thuhole-config@master/main.txt"
        static let pkuConfigURL = "https://cdn.jsdelivr.net/gh/pkuhollow/pkuhollow-config@main/config.txt"
        static let otherConfigs: [String : String] = [
            "北化树洞" : "https://cdn.jsdelivr.net/gh/bucthole/bucthole-config@master/config.txt",
            "JLU树洞" : "https://cdn.jsdelivr.net/gh/i-Yirannn/jluhole-config/main.txt"
        ]
    }

    enum Net {
        static let urlSuffix = "?v=v\(Constants.Application.appVersion)&device=2"
        static let apiTestPath = "generate_204"
    }
}

extension Constants.Application {
    #if !WIDGET
    static let deviceInfo = DeviceModelUtilities.modelIdentifier +
        " (\(UIDevice.isMac ? "Mac Catalyst" : UIDevice.current.systemName) " +
        UIDevice.current.systemVersion + ")"
    #else
    static let deviceInfo = ""
    #endif
}
