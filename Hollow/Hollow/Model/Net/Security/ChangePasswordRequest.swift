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
    var oldHashedPassword: String
    /// New hashed password
    var newHashedPassword: String
    
    var hollowConfig: GetConfigRequestResult
}

/// Result of an changing password attempt.
struct ChangePasswordRequestResult: Codable {
    /// Result type of changing password.
    /// The type of result received.
    var code: Int
    /// Error mssage.
    var msg: String?
}

struct ChangePasswordRequest: Request {
    typealias Configuration = ChangePasswordRequestConfiguration
    typealias Result = ChangePasswordRequestResult
    typealias ResultData = ChangePasswordRequestResult
    typealias Error = DefaultRequestError
    
    var configuration: ChangePasswordRequestConfiguration
    
    init(configuration: ChangePasswordRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(
        completion: @escaping (ChangePasswordRequestResult?, DefaultRequestError?) -> Void
    ) {
        let parameters =
            [
                "email": self.configuration.email,
                "old_password_hashed": self.configuration.oldHashedPassword,
                "new_password_hashed": self.configuration.newHashedPassword,
            ] as [String: String]
        let urlPath =
            self.configuration.hollowConfig.apiRoot + "v3/security/login/change_password" + self
            .configuration.hollowConfig.urlSuffix!
        AF.request(
            urlPath,
            method: .post,
            parameters: parameters,
            encoder: URLEncodedFormParameterEncoder.default
        )
        .validate().responseJSON { response in
            switch response.result {
            case .success:
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    // FIXME: NOT TESTED YET
                    let result = try jsonDecoder.decode(
                        ChangePasswordRequestResult.self, from: response.data!)
                    if result.code >= 0 {
                        completion(result, nil)
                    } else {
                        // invalid response
                        completion(
                            nil, .other(description: result.msg ?? "error code from backend: \(result.code)"))
                    }
                } catch {
                    completion(nil, .decodeError)
                    return
                }
            case .failure(let error):
                completion(
                    nil,
                    .other(
                        description: error.errorDescription ?? "Unkown error when performing ChangePassword!"))
            }
        }
        
    }
}
