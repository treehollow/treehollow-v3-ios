//
//  LoginRequest.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/18.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Alamofire
import UIKit

struct LoginRequestConfiguration {
    var email: String
    var hashedPassword: String
    let deviceType = 2
    let deviceInfo = UIDevice.current.name
    // TODO: Device token
    var deviceToken: String
    
    var hollowConfig: GetConfigRequestResult
}

struct LoginRequestResult: Codable {
    var code: Int
    var token: String
    var uuid: UUID
    var msg: String?
}

struct LoginRequestResultData {
    var token: String
    var uuid: UUID
}

struct LoginRequest: Request {
    
    typealias Configuration = LoginRequestConfiguration
    typealias Result = LoginRequestResult
    typealias ResultData = LoginRequestResultData
    typealias Error = DefaultRequestError
    
    var configuration: LoginRequestConfiguration
    
    init(configuration: LoginRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (LoginRequestResultData?, DefaultRequestError?) -> Void)
    {
        let parameters =
            [
                "email": self.configuration.email,
                "password_hashed": self.configuration.hashedPassword,
                "device_type": self.configuration.deviceType,
                "device_info": self.configuration.deviceInfo,
                "ios_device_token": self.configuration.deviceToken,
            ] as! [String: String]
        let urlPath =
            self.configuration.hollowConfig.apiRoot + "v3/security/login/login" + self.configuration
            .hollowConfig.urlSuffix!
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
                    let result = try jsonDecoder.decode(LoginRequestResult.self, from: response.data!)
                    if result.code >= 0 {
                        // result code >= 0 valid!
                        let resultData = LoginRequestResultData(token: result.token, uuid: result.uuid)
                        completion(resultData, nil)
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
                    nil, .other(description: error.errorDescription ?? "Unkown error when performing Login!"))
            }
        }
        
    }
}
