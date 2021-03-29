//
//  HollowConfig.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/24.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

struct HollowConfig: Codable {
    struct SearchPrompt: Codable {
        struct ButtonInfo: Codable {
            var text: String
            var url: String
        }
        var keywords: [String]
        var description: String
        var buttons: [ButtonInfo]
    }
    var name: String
    var recaptchaUrl: String
    var apiRootUrls: [String]
    var tosUrl: String
    var rulesUrl: String
    var privacyUrl: String
    var contactEmail: String
    var emailSuffixes: [String]
    var announcement: String
    var foldTags: [String]
    var reportableTags: [String]
    var sendableTags: [String]
    var imgBaseUrls: [String]
    var websocketUrl: String
    var searchTrending: String
    var searchPrompts: [SearchPrompt]
}
