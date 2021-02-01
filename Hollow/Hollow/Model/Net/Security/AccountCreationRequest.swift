//
//  AccountCreation.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import UIKit
import Alamofire

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
    // var oldToken: String?
    /// Email valid code, optional, but one of `oldToken` and `validCode` must be present.
    var validCode: String?
    // TODO: Device token for APNs
    var deviceToken: String
    /// See `AccountCreationConfiguration`
    ///
    var hollowConfig: GetConfigRequestResult
    //    /// Returns nil when both `oldToken` and `validCode` are `nil`.
    //    init?(email: String, hashedPassword: String, oldToken: String?, validCode: String?) {
    //        // Check for invalid configuration
    //        if oldToken == nil && validCode == nil { return nil }
    //        self.email = email
    //        self.hashedPassword = hashedPassword
    //        //self.oldToken = oldToken
    //        self.validCode = validCode
    //    }
}

/// Result of account creation attempt.
struct AccountCreationRequestResultData {
    /// Result type of account creation.
    ///
    /// Please init with `AccountCreationRequestResult.ResultType(rawValue: Int)`, and should
    /// show error with `nil`, which means receiving negative code.
//    enum ResultType: Int {
//        case success = 0
//    }
//    /// The type of result received.
//    var code: ResultType
    /// Access token.
    var token: String
    /// Device UUID
    var uuid: UUID
    /// Error mssage.
    //var message: String?
}

struct AccountCreationRequestResult: Codable {
    /// The type of result received.
    var code: Int
    /// Access token.
    var token: String
    /// Device UUID
    var uuid: UUID
    /// Error mssage.
    var msg: String?
}

struct AccountCreationRequest: Request {
    typealias Configuration = AccountCreationRequestConfiguration
    typealias Result = AccountCreationRequestResult
    typealias ResultData = AccountCreationRequestResultData
    typealias Error = DefaultRequestError
//    enum AccountCreationRequestError: RequestError{
//        case decodeError
//        case other(description: String)
//        var description: String{
//            switch self {
//            case .decodeError: return "Decode failed"
//            case .other(let description): return description
//            }
//        }
//    }
    
    var configuration: AccountCreationRequestConfiguration
    
    init(configuration: AccountCreationRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (AccountCreationRequestResultData?, DefaultRequestError?) -> Void){
        var parameters = ["email" : self.configuration.email,
                          "password_hashed": self.configuration.hashedPassword,
                          "device_type": self.configuration.deviceType,
                          "device_info": self.configuration.deviceInfo,
                          "ios_device_token": self.configuration.deviceToken
        ] as! [String : String]
        
        if let validCode = self.configuration.validCode {
            parameters["valid_code"] = validCode
        }
        
        let urlPath = self.configuration.hollowConfig.apiRoot + "/v3/security/login/create_account" + self.configuration.hollowConfig.urlSuffix!
        AF.request(urlPath,
                   method: .post,
                   parameters: parameters,
                   encoder: URLEncodedFormParameterEncoder.default).validate().responseJSON{ response in
//            .validate(statusCode: 200..<300)
//            .validate(contentType: ["application/json"])
//            .responseData{ response in
                switch response.result{
                case .success:
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        // FIXME: NOT TESTED YET
                        let result = try jsonDecoder.decode(AccountCreationRequestResult.self, from: response.data!)
                        if result.code >= 0{
                            // result code >= 0 valid!
                            let resultData = AccountCreationRequestResultData(token: result.token, uuid: result.uuid)
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
                case .failure(let error):
                    completion(nil,.other(description: error.errorDescription ?? ""))
                }
            }
    }
}
