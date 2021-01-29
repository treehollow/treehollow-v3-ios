//
//  EmailCheck.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import Foundation
import Networking

/// Configurations for email check
struct EmailCheckRequestConfiguration {
    /// `reCAPTCHA` version
//    NO USE!
//    enum ReCAPTCHAVersion: String {
//        case v2 = "v2"
//        case v3 = "v3"
//    }
    /// User's email to be checked, required
    var email: String
    /// User's old thuhole token, only needed for old user signup
    /// using web frontend, optional
    // var oldToken: String?
    /// Info of `reCAPTCHA`, optional
    // NO USE
    //var reCAPTCHAInfo: (token: String, version: ReCAPTCHAVersion)?
    /// constant used for http request
    var hollowConfig: GetConfigRequestResult
}

/// Result data of email checking.
struct EmailCheckRequestResult: Codable{
    /// Result type of email checking.
    ///
    /// Please init with `EmailCheckRequest.ResultType(rawValue: Int)`, and should
    /// show error with `nil`, which means receiving negative code.
    enum ResultType: Int,Codable {
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
    var code: ResultType
    /// Error message, if error occured.
    var msg: String?
}

class EmailCheckRequest: Request{
   
    typealias Configuration = EmailCheckRequestConfiguration
    typealias Result = EmailCheckRequestResult
    typealias ResultData = Result
    typealias Error = EmailCheckRequestError
    enum EmailCheckRequestError: RequestError{
        case decodeError
        case other(description: String)
        var description: String{
            switch self {
            case .decodeError: return "Decode failed"
            case .other(let description): return description
            }
        }
    }
    var configuration: EmailCheckRequestConfiguration
    required init(configuration: EmailCheckRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (Result?, EmailCheckRequestError?) -> Void) {
        let parameters = ["email" : self.configuration.email]
        let urlPath = "/v3/security/login/check_email" + self.configuration.hollowConfig.urlSuffix!
        // URL must be leagle !
        let networking = Networking(baseURL: self.configuration.hollowConfig.apiRoot)
        networking.post(urlPath, parameters: parameters) { result in
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
           // Successfull post using `application/json` as `Content-Type`
            switch result{
            case .success(let response):
                do {
                    // FIXME: NOT TESTED YET
                    let result = try jsonDecoder.decode(EmailCheckRequestResult.self, from: response.data)
                    completion(result,nil)
                } catch {
                    completion(nil,.decodeError)
                    return
                }
                // If we need headers or response status code we can use the HTTPURLResponse for this.
                //let headers = response.headers // [String: Any]
            case .failure(let response):
                // Non-optional error ✨
                let errorCode = response.error.code

                // Our backend developer told us that they will send a json with some
                // additional information on why the request failed, this will be a dictionary.
                let errorResponse = String(data: response.data, encoding: .utf8) ?? ""// BOOM, no optionals here [String: Any]
                let errormsg = String(errorCode) + errorResponse
                completion(nil,.other(description: errormsg))
                // We want to know the headers of the failed response.
                //let headers = response.headers // [String: Any]
            }
        }
    }
}
