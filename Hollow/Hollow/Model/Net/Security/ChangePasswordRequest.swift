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
    var apiRoot: String
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
        completion: @escaping (ResultData?, Error?) -> Void
    ) {
        let parameters =
            [
                "email": self.configuration.email,
                "old_password_hashed": self.configuration.oldPassword.sha256().sha256(),
                "new_password_hashed": self.configuration.newPassword.sha256().sha256(),
            ] as [String: String]
        let urlPath =
            self.configuration.apiRoot + "v3/security/login/change_password" + Constants.URLConstant.urlSuffix
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
                    let result = try jsonDecoder.decode(Result.self, from: response.data!)
                    if result.code >= 0 {
                        completion(result, nil)
                    } else {
                        // invalid response
                        var error = DefaultRequestError()
                        error.initbyCode(errorCode: result.code, description: result.msg)
                        completion(nil, error)
                    }
                } catch {
                    completion(nil, DefaultRequestError(errorType: .decodeFailed))
                    return
                }
            case .failure(let error):
                completion(
                    nil,DefaultRequestError(errorType: .other(description: error.localizedDescription)))
            }
        }
    }
}
