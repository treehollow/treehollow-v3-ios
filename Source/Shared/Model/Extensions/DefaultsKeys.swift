//
//  DefaultsKeys.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/20.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Defaults
import Foundation
import SwiftUI

/// Store default's key here when firstly introduce it.
/// Store the keys for `Defaults` here, declaring them static const member of `Defaults.Keys`
/// For example:
/// `static let imageBaseURL = Key<String?>("image.base.url")`

let sharedDefaults = UserDefaults(suiteName: "group.treehollow.Hollow")!

// MARK: - Model Data
extension Defaults.Keys {
    /// Hollow type
    static let hollowType = Key<HollowType?>("config.hollow.type")
    /// Hollow config
    static let hollowConfig = Key<HollowConfig?>("net.hollow.config", suite: sharedDefaults)
    /// Custom hollow config url
    static let customConfigURL = Key<String?>("net.hollow.config.custom.url")
    /// APN device token
    static let deviceToken = Key<Data?>("user.device.token")
    /// User access token
    static let accessToken = Key<String?>("user.access.token", suite: sharedDefaults)
    /// Auto line switch result
    static let orderdLineStorage = Key<LineSwitchManager.OrderedLineStorage?>("net.hollow.lineswitch.orderdlinestorage")
    /// Announcement explictly hidden by the user.
    static let hiddenAnnouncement = Key<String>("user.hidden.announcement", default: "")
    
    static let latestViewedUpdateVersion = Key<String?>("user.latest.viewed.update.version")
}


// MARK: - UI
extension Defaults.Keys {
    /// Search history.
    static let searchHistory = Key<[String]>("user.search.history", default: [])
}


// MARK: - Cache
extension Defaults.Keys {
    #if !WIDGET
    static let deviceListCache = Key<DeviceListRequestResultData?>("cache.device.list")
    static let notificationTypeCache = Key<PushNotificationType>("cache.push.notification.type", default: .init())
    static let versionUpdateInfoCache = Key<UpdateAvailabilityRequestResult.Result?>("cache.version.update.info")
    #endif
}


// MARK: - User Settings
// Defaults for user settings
#if os(macOS) && !targetEnvironment(macCatalyst)
extension Defaults.Keys {
    
}
#else
extension Defaults.Keys {
    static let foldPredefinedTags = Key<Bool>("user.settings.fold.predifined.tags", default: true)
    /// Additional tags to be blocked
    static let blockedTags = Key<[String]>("user.settings.blocked.tags", default: [])
    #if !WIDGET
    /// Color scheme that user selects (default: same as system)
    static let colorScheme = Key<CustomColorScheme>("user.settings.color.scheme", default: .system)
    /// Color set selected by user
    static let customColorSet = Key<ColorSet?>("user.settings.custom.color.set", default: nil)
    /// Whether to apply custom color set. Set to true when restart the application.
    static let applyCustomColorSet = Key<Bool>("user.settings.custom.apply.color.set", default: false)
    /// Store the custom color set until apply in the next startup.
    static let tempCustomColorSet = Key<ColorSet?>("user.settings.temp.custom.color.set", default: nil)
    /// The method to handle links.
    static let openURLMethod = Key<OpenURLHelper.OpenMethod>("user.settings.open.url.method", default: .inApp)
    #endif
    /// Whether to show an alert when the update is available.
    static let showUpdateAlert = Key<Bool>("user.settings.show.update.alert", default: true)
    
    static let usingSimpleAvatar = Key<Bool>("user.settings.using.simple.avatar", default: true)
}

// MARK: - Experimental Features
extension Defaults.Keys {
    static let reduceImageQuality = Key<Bool>("user.settings.reduce.image.quality", default: false)
    static let useListInDetail = Key<Bool>("user.settings.use.list.in.detail", default: false)
}
#endif

#if WIDGET
extension Defaults.Keys {
    static let lastLoadDate = Key<Date?>("widget.last.load.date")
}
#endif
