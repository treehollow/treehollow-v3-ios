//
//  SystemMessageRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation

/// The configuration parameter is the user token.
typealias SystemMessageRequestConfiguration = String

/// Wrapper for result of attempt to get system messages
struct SystemMessageRequestResult {
    /// Result type of getting system messages.
    ///
    /// Please init with `SystemMessageRequestResult.ResultType(rawValue: Int)`, and should
    /// show error with `nil`, which means receiving negative code.
    enum ResultType: Int {
        case success = 0
    }
    
    /// The type of result received.
    var type: ResultType
    /// All system messages
    var messages: [SystemMessage]
}
