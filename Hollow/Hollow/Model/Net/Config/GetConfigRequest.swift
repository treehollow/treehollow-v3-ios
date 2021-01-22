//
//  GetConfigRequest.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/18.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

// No configurations for config request as it takes no parameters.

/// Result of requesting system config.
struct GetConfigRequestResult {
    var name: String
    // FIXME: Int or String
    var reCAPTCHAV3Key: Int
    var reCAPTCHAV2Key: Int
    var apiRoot: String
    var tosUrl: String
    var privacyUrl: String
    var contactEmail: String
    var emailSuffixes: [String]
    var announcement: String
    var foldTags: [String]
    var sendableTags: [String]
    var imageBaseUrl: String
    var imageBaseUrlBak: String
    // FIXME: existing ios frontend version
}
