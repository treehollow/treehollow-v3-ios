//
//  Localization.swift
//  Hollow
//
//  Created by 梁业升 on 2021/2/2.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

/// Store some repeatedly used localized string key here.
/// Keep the keys lowercased.
extension String {
    static let internalErrorLocalized = NSLocalizedString("internal error", comment: "")
    static let errorLocalized = NSLocalizedString("error", comment: "")
    static let emailAddressLocalized = NSLocalizedString("email address", comment: "")
    static let emailVerificationCodeLocalized = NSLocalizedString("email verification code", comment: "")
    static let passWordLocalized = NSLocalizedString("password", comment: "")
    static let confirmedPassWordLocalized = NSLocalizedString("confirmed password", comment: "")
    static let wanderLocalized = NSLocalizedString("wander", comment: "")
    static let timelineLocalized = NSLocalizedString("timeline", comment: "")
    static let searchLocalized = NSLocalizedString("search", comment: "")
    static let advancedLocalized = NSLocalizedString("advanced", comment: "")
    static let historyLocalized = NSLocalizedString("history", comment: "")
    static let timeLocalized = NSLocalizedString("time", comment: "")
    static let rangeLocalized = NSLocalizedString("range", comment: "")
    static let invalidInputLocalized = NSLocalizedString("invalid input", comment: "")
    static let loginLocalized = NSLocalizedString("login", comment: "")
    static let continueLocalized = NSLocalizedString("continue", comment: "")
}

extension String {
    var firstLetterUppercased: String {
        if self == "" { return self }
        return self.first!.uppercased() + self.dropFirst()
    }
}
