//
//  EmailCheck.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import Foundation

/// Configurations for email check
struct EmailCheckRequestConfiguration {
    /// `reCAPTCHA` version
    enum ReCAPTCHAVersion: String {
        case v2 = "v2"
        case v3 = "v3"
    }
    /// User's email to be checked, required
    var email: String
    /// User's old thuhole token, only needed for old user signup
    /// using web frontend, optional
    var oldToken: String?
    /// Info of `reCAPTCHA`, optional
    var reCAPTCHAInfo: (token: String, version: ReCAPTCHAVersion)?
}

/// Result of email checking.
struct EmailCheckRequestResult {
    /// Result type of email checking.
    ///
    /// Please init with `EmailCheckRequest.ResultType(rawValue: Int)`, and should
    /// show error with `nil`, which means receiving negative code.
    enum ResultType: Int {
        /// Old user, shuold input password to login.
        case oldUser = 0
        /// New user, should check email for valid code and create password to sign up.
        case newUser = 1
        /// New user with old thuhole token, should create password to sign up.
        case newUserWithToken = 2
        /// Need recatpcha verification, we need to create a recaptcha popover.
        case reCAPTCHANeeded = 3
    }
    
    /// The type of result received.
    var type: ResultType
    /// Error message, if error occured.
    var message: String?
}
