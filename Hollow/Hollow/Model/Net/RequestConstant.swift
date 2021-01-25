//
//  RequestConstant.swift
//  Hollow
//
//  Created by aliceinhollow on 2021/1/24.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Defaults

/// Request Constant helper class
class RequestCostant: Encodable,Decodable {
    var apiRoot: String?
    var urlSuffix: String?
    /// - parameter apiroot: apiroot .
    /// - parameter appVersion: appversion like 1.2.3
    init(apiroot: String, appVersion: String) {
        self.apiRoot = apiroot
        /// `device=2` for IOS
        self.urlSuffix = "?v=v\(appVersion)&device=2"
    }
}
