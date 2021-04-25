//
//  Constants.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/3.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import UserNotifications

#if !os(macOS)
import UIKit
#endif

/// Shared constants.
///
/// The purpose of the nested structs is to provide namespaces.
struct Constants {
    struct Application {
        static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        static let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        static let appLocalizedName =
            Bundle.main.localizedInfoDictionary?["CFBundleName"] as? String ??
            Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
        static let requestedNotificationOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    }
    
    struct HollowConfig {
        static let thuConfigURL = "https://cdn.jsdelivr.net/gh/treehollow/thuhole-config@master/main.txt"
        static let pkuConfigURL = "https://cdn.jsdelivr.net/gh/pkuhollow/pkuhollow-config@master/config.txt"
    }

    struct Net {
        static let urlSuffix = "?v=v\(Constants.Application.appVersion)&device=2"
        static let apiTestPath = "generate_204"
    }
}

extension Constants.Application {
    #if !os(macOS)
    static let deviceInfo = DeviceModelUtilities.modelIdentifier +
        " (\(UIDevice.isMac ? "Mac Catalyst" : UIDevice.current.systemName) " +
        UIDevice.current.systemVersion + ")"
    #else
    // FIXME
    static let deviceInfo = ""
    #endif
}
