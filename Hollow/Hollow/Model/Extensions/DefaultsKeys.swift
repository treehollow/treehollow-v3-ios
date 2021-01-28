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
extension Defaults.Keys {
    /// Request API Constants
    static let netRequestConst = Key<RequestConstant?>("net.RequestCostant")
    /// Global color set to use
    static let hollowType = Key<HollowType?>("config.hollow.type")
}
