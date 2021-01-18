//
//  AccountCreation.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import UIKit

/// Configuraions for creating an account.
struct AccountCreationRequestConfiguration {
    /// User's email.
    var email: String
    /// sha256 of user's password.
    var hashedPassword: String
    /// Device type, 2 for iOS.
    let deviceType = 2
    /// Device name.
    let deviceInfo: String = UIDevice.current.name
    /// Old thuhole token (only needed for old users signing up using web frontend),
    /// optional, but one of `validCode` and `oldToken` must be present.
    var oldToken: String?
    /// Email valid code, optional, but one of `oldToken` and `validCode` must be present.
    var validCode: String?
    
    /// See `AccountCreationConfiguration`
    ///
    /// Returns nil when both `oldToken` and `validCode` are `nil`.
    init?(email: String, hashedPassword: String, oldToken: String?, validCode: String?) {
        // Check for invalid configuration
        if oldToken == nil && validCode == nil { return nil }
        self.email = email
        self.hashedPassword = hashedPassword
        self.oldToken = oldToken
        self.validCode = validCode
    }
}

/// Result of account creation attempt.
struct AccountCreationRequestResult {
    /// Result type of account creation.
    ///
    /// Please init with `AccountCreationRequestResult.ResultType(rawValue: Int)`, and should
    /// show error with `nil`, which means receiving negative code.
    enum ResultType: Int {
        case success = 0
    }
    
    /// The type of result received.
    var type: ResultType
    /// Access token.
    var token: String
    /// Device UUID
    var uuid: UUID
    /// Error mssage.
    var message: String?
}
