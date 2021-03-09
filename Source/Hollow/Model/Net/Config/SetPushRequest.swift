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
    var apiRoot: [String]
    var token: String
}

struct SetPushRequestResult: DefaultRequestResult {
    var code: Int
    var msg: String?
}

enum SetPushRequestResultData: Int {
    case success = 0
}

struct SetPushRequest: DefaultRequest {
    typealias Configuration = SetPushRequestConfiguration
    typealias Result = SetPushRequestResult
    typealias ResultData = SetPushRequestResultData
    typealias Error = DefaultRequestError
    
    var configuration: SetPushRequestConfiguration
    
    init(configuration: SetPushRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (SetPushRequestResultData?, DefaultRequestError?) -> Void) {
        let urlPath = "v3/config/set_push" + Constants.Net.urlSuffix
        let parameters = [
            "push_system_msg": self.configuration.type.pushSystemMsg.int,
            "push_reply_me": self.configuration.type.pushReplyMe.int,
            "push_favorited": self.configuration.type.pushFavorited.int,
        ]
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]
        performRequest(
            urlBase: self.configuration.apiRoot,
            urlPath: urlPath,
            parameters: parameters,
            headers: headers,
            method: .post,
            transformer: { result in
                ResultData.init(rawValue: result.code)
            },
            completion: completion
        )
    }
}
