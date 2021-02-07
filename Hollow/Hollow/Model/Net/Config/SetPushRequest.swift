//
//  SetPushRequest.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/22.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Alamofire

struct SetPushRequestConfiguration {
    var type: PushNotificationType
    var apiRoot: String
    var token: String
}

struct SetPushRequestResult: Codable {
    var code: Int
}
enum SetPushRequestResultData: Int {
    case success = 0
}

struct SetPushRequest: Request {
    typealias Configuration = SetPushRequestConfiguration
    typealias Result = SetPushRequestResult
    typealias ResultData = SetPushRequestResultData
    typealias Error = DefaultRequestError
    
    var configuration: SetPushRequestConfiguration
    
    init(configuration: SetPushRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (SetPushRequestResultData?, DefaultRequestError?) -> Void) {
        let urlPath = self.configuration.apiRoot + "v3/config/set_push" + Constants.URLConstant.urlSuffix
        let parameters = [
            "push_system_msg": self.configuration.type.pushSystemMsg ? 1 : 0,
            "push_reply_me": self.configuration.type.pushReplyMe ? 1 : 0,
            "push_favorited": self.configuration.type.pushFavorited ? 1 : 0,
        ]
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]
        AF.request(
            urlPath,
            method: .post,
            parameters: parameters,
            encoder: URLEncodedFormParameterEncoder.default,
            headers: headers
        ).validate().responseJSON { response in
            switch response.result {
            case .success:
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let result = try jsonDecoder.decode(Result.self, from: response.data!)
                    if result.code >= 0 {
                        // result code >= 0 valid!
                        let resultData = ResultData.init(rawValue: result.code)
                        completion(resultData, nil)
                        //debugPrint(response.response?.allHeaderFields)
                    } else {
                        // invalid response
                        completion(
                            nil, .other(description: "Received error code from backend: \(result.code)."))
                    }
                } catch {
                    completion(nil, .decodeFailed)
                    return
                }
            case let .failure(error):
                completion(
                    nil,
                    .other(description: error.errorDescription ?? "Unkown error when performing SetPushRequest!"))
            }
        }
    }
}
