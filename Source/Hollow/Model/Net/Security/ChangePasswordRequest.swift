//
//  ChangePassword.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import Alamofire
import Foundation

/// Configurations for changing password.
struct ChangePasswordRequestConfiguration {
    /// User's email
    var email: String
    /// Previous hashed password
    var oldPassword: String
    /// New hashed password
    var newPassword: String
    var apiRoot: [String]
}

/// Result of an changing password attempt.
struct ChangePasswordRequestResult: DefaultRequestResult {
    /// Result type of changing password.
    /// The type of result received.
    var code: Int
    /// Error mssage.
    var msg: String?
}

struct ChangePasswordRequest: DefaultRequest {
    typealias Configuration = ChangePasswordRequestConfiguration
    typealias Result = ChangePasswordRequestResult
    typealias ResultData = ChangePasswordRequestResult
    typealias Error = DefaultRequestError
    
    var configuration: ChangePasswordRequestConfiguration
    
    init(configuration: ChangePasswordRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (ResultData?, Error?) -> Void) {
        let parameters = [
            "email": self.configuration.email,
            "old_password_hashed": self.configuration.oldPassword.sha256().sha256(),
            "new_password_hashed": self.configuration.newPassword.sha256().sha256(),
        ]
        let urlPath = "v3/security/login/change_password" + Constants.URLConstant.urlSuffix
        performRequest(
            urlBase: self.configuration.apiRoot,
            urlPath: urlPath,
            parameters: parameters,
            method: .post,
            transformer: { $0 },
            completion: completion
        )
    }
}
