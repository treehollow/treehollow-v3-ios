//
//  ChangePassword.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import Foundation

/// Configurations for changing password.
struct ChangePasswordRequestConfiguration {
    /// User's email
    var email: String
    /// Previous hashed password
    var oldHashedPassword: String
    /// New hashed password
    var newHashedPassword: String
}

/// Result of an changing password attempt.
struct ChangePasswordRequestResult {
    /// Result type of changing password.
    ///
    /// Please init with `ChangePasswordRequestResult.ResultType(rawValue: Int)`, and should
    /// show error with `nil`, which means receiving negative code.
    enum ResultType: Int {
        case success = 0
    }
    
    /// The type of result received.
    var type: ResultType
    /// Error mssage.
    var message: String?
}
