//
//  DefaultsKeys.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/20.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Defaults
import Foundation

/// Store default's key here when firstly introduce it.
/// Store the keys for `Defaults` here, declaring them static const member of `Defaults.Keys`
/// For example:
/// `static let imageBaseURL = Key<String?>("image.base.url")`
/// Remember to register the initial value before any call to fetch the data.

// MARK: - Model Data
extension Defaults.Keys {
    /// Hollow type
    static let hollowType = Key<HollowType?>("config.hollow.type")
    /// Hollow config
    static let hollowConfig = Key<HollowConfig?>("net.hollow.config")
    /// Custom hollow config url
    static let customConfigURL = Key<String?>("net.hollow.config.custom.url")
    /// APN device token
    static let deviceToken = Key<Data?>("user.device.token")
    /// User access token
    static let accessToken = Key<String?>("user.access.token")
    /// Auto line switch result
    static let orderdLineStorage = Key<LineSwitchManager.OrderdLineStorage?>("net.hollow.lineswitch.orderdlinestorage")
}


// MARK: - UI
extension Defaults.Keys {
    /// Whether the user uses advanced search in `SearchView`
    static let searchViewShowsAdvanced = Key<Bool>("search.shows.advanced", default: false)
}


// MARK: - Cache
// We store some result from the requests in the defaults to
// cache the lastest results, but just for placeholder use.
extension Defaults.Keys {
    static let deviceListCache = Key<DeviceListRequestResultData?>("cache.device.list")
}
