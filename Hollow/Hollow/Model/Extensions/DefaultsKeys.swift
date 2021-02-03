//
//  DefaultsKeys.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/20.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Defaults

/// Store default's key here when firstly introduce it.
/// Store the keys for `Defaults` here, declaring them static const member of `Defaults.Keys`
/// For example:
/// `static let imageBaseURL = Key<String?>("image.base.url")`
/// Remember to register the initial value before any call to fetch the data.

// MARK: - Model
extension Defaults.Keys {
    /// Hollow type
    static let hollowType = Key<HollowType?>("config.hollow.type")
    /// Hollow config
    static let hollowConfig = Key<GetConfigRequestResult?>("net.hollow.config")
}


// MARK: - View
extension Defaults.Keys {
    /// Whether the user uses advanced search in `SearchView`
    static let searchViewShowsAdvanced = Key<Bool>("search.shows.advanced", default: false)
}
