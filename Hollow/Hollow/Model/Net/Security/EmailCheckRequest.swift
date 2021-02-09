//
//  EmailCheck.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import Alamofire
import Foundation

/// Configurations for email check
struct EmailCheckRequestConfiguration {
    /// `reCAPTCHA` version
    //    NO USE!
    enum ReCAPTCHAVersion: String {
        case v2 = "v2"
        case v3 = "v3"
    }
    /// User's email to be checked, required
    var email: String

    /// Info of `reCAPTCHA`, optional
    var reCAPTCHAInfo: (token: String, version: ReCAPTCHAVersion)?
    
    var apiRoot: String
}

/// Result Data of EmailCheck
struct EmailCheckRequestResultData {
    /// Result type of email checking.
    ///
    /// Please init with `EmailCheckRequest.ResultType(rawValue: Int)`, and should
    /// show error with `nil`, which means receiving negative code.
    enum ResultType: Int, Equatable {
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
    var result: ResultType
    /// Error message, if error occured.
    //var massage: String?
}

/// Result of email checking.
struct EmailCheckRequestResult: DefaultRequestResult {
    var code: Int
    var msg: String?
}

struct EmailCheckRequest: DefaultRequest {
    
    typealias Configuration = EmailCheckRequestConfiguration
    typealias Result = EmailCheckRequestResult
    typealias ResultData = EmailCheckRequestResultData
    typealias Error = DefaultRequestError

    var configuration: EmailCheckRequestConfiguration
    
    init(configuration: EmailCheckRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (ResultData?, DefaultRequestError?) -> Void) {
        // manually assigned parameter. better if it can be initialized automatically
        var parameters = ["email": self.configuration.email]
        if let reCAPTCHAInfo = self.configuration.reCAPTCHAInfo {
            parameters["recaptcha_version"] = reCAPTCHAInfo.version.rawValue
            parameters["recaptcha_token"] = reCAPTCHAInfo.token
        }
        let urlPath =
            self.configuration.apiRoot + "v3/security/login/check_email" + Constants.URLConstant.urlSuffix
        // URL must be legal!
        performRequest(
            urlPath: urlPath,
            parameters: parameters,
            headers: nil,
            method: .post,
            resultToResultData: { result in
                guard let resultType = EmailCheckRequestResultData.ResultType.init(rawValue: result.code) else { return nil }
                return EmailCheckRequestResultData(result: resultType)
            },
            completion: completion
        )
    }
}
