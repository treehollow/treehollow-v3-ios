//
//  GetConfigRequest.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/18.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

/// config of GetConfig query
struct GetConfigRequestConfiguration {
    var APIRoot: String
    //FIXME: get app version
    //var appVersion: String
}

/// Result of requesting system config.
struct GetConfigRequestResult: Codable {
    var name: String
    var reCAPTCHAV3Key: String
    var reCAPTCHAV2Key: String
    var allowScreenShot: Bool
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
    var websocketUrl: String
    // FIXME: existing ios frontend version
}

/// Get Config Request
class GetConfigRequest {
    init(config: GetConfigRequestConfiguration) {
    }
}
