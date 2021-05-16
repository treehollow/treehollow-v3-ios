//
//  VersionUpdateUtilities.swift
//  Hollow
//
//  Created by liang2kl on 2021/4/27.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Defaults
import SwiftUI
import UserNotifications

struct VersionUpdateUtilities {
    static func handleUpdateAvailabilityResult(data: UpdateAvailabilityRequest.ResultData?) {
        guard let data = data else {
            Defaults[.versionUpdateInfoCache] = nil
            return
        }
        
        // The current version is the latest version
        if !data.0 {
            Defaults[.latestViewedUpdateVersion] = nil
            Defaults[.versionUpdateInfoCache] = nil
            return
        }
        Defaults[.versionUpdateInfoCache] = data.1
        
        // Whether we have shown the update popover already.
        // If shown, we will try to present an notification alert
        // based on the settings.
        if Defaults[.latestViewedUpdateVersion] == data.1.version {
            guard Defaults[.showUpdateAlert] else { return }
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(
                options: Constants.Application.requestedNotificationOptions,
                completionHandler: { granted, _ in
                    guard granted else { return }
                    let content = UNMutableNotificationContent()
                    content.title = NSLocalizedString("VERSION_UPDATE_VIEW_NAV_TITLE", comment: "")
                    content.subtitle = NSLocalizedString("ABOUTVIEW_VERSION", comment: "") + " " + data.1.version
                    content.body = data.1.releaseNotes
                    content.userInfo["url"] = data.1.trackViewUrl
                    
                    let request = UNNotificationRequest(
                        identifier: "VERSION_UPDATE",
                        content: content,
                        trigger: nil
                    )
                    center.add(request, withCompletionHandler: nil)
                }
            )
            return
        }
        Defaults[.latestViewedUpdateVersion] = data.1.version
        IntegrationUtilities.presentView { NavigationView { VersionUpdateView(info: data.1, showItem: true) }}
    }
}
