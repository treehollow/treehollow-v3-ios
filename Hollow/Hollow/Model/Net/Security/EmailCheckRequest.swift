//
//  EmailCheck.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import Foundation
import Alamofire

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

/// Result Data of EmailCheck
struct EmailCheckRequestResultData {
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
    var result: ResultType
    /// Error message, if error occured.
    //var massage: String?
}

/// Result of email checking.
struct EmailCheckRequestResult: Codable {
    var code: Int
    var msg: String?
}


struct EmailCheckRequest: Request {
    
    typealias Configuration = EmailCheckRequestConfiguration
    typealias Result = EmailCheckRequestResult
    typealias ResultData = EmailCheckRequestResultData
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
    init(configuration: EmailCheckRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (ResultData?, EmailCheckRequestError?) -> Void) {
        // manually assigned parameter. better if it can be initialized automatically
        let parameters = ["email" : self.configuration.email]
        let urlPath = self.configuration.hollowConfig.apiRoot + "/v3/security/login/check_email" + self.configuration.hollowConfig.urlSuffix!
        // URL must be leagle !
        AF.request(urlPath,
                   method: .post,
                   parameters: parameters,
                   encoder: URLEncodedFormParameterEncoder.default)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData{ response in
                switch response.result {
                case .success:
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        // FIXME: NOT TESTED YET
                        let result = try jsonDecoder.decode(EmailCheckRequestResult.self, from: response.data!)
                        if result.code >= 0{
                            // result code >= 0 valid!
                            let resultData = EmailCheckRequestResultData(
                                result: EmailCheckRequestResultData.ResultType(rawValue: result.code)!)
                            completion(resultData,nil)
                        }
                        else{
                            // invalid response
                            completion(nil,.other(description: result.msg ?? "error code from backend: \(result.code)"))
                        }
                    } catch {
                        completion(nil,.decodeError)
                        return
                    }
                case let .failure(error):
                    completion(nil,.other(description: error.errorDescription ?? "Unkown error when performing EmailCheck!"))                }
            }
    }
}
