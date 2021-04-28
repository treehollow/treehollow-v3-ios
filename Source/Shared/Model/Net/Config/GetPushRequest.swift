//
//  GetPushRequest.swift
//  Hollow
//
//  Created by aliceinhollow on 7/2/2021.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Alamofire

struct GetPushRequestConfiguration {
    var apiRoot: [String]
    var token: String
}

struct GetPushRequestResult: DefaultRequestResult {
    struct PushNotificationResult: Codable {
        var pushSystemMsg: Int
        var pushReplyMe: Int
        var pushFavorited: Int
    }
    var code: Int
    var msg: String?
    var data: PushNotificationResult?
}

typealias GetPushRequestResultData = PushNotificationType

struct GetPushRequest: DefaultRequest {
    
    typealias Configuration = GetPushRequestConfiguration
    typealias Result = GetPushRequestResult
    typealias ResultData = GetPushRequestResultData
    typealias Error = DefaultRequestError
    var configuration: GetPushRequestConfiguration
    
    init(configuration: GetPushRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (GetPushRequestResultData?, DefaultRequestError?) -> Void) {
        let urlPath = "v3/config/get_push" + Constants.Net.urlSuffix
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]
        performRequest(
            urlBase: self.configuration.apiRoot,
            urlPath: urlPath,
            headers: headers,
            method: .get,
            transformer: { result in
                guard let data = result.data else {return nil}
                return ResultData(pushSystemMsg: data.pushSystemMsg.bool, pushReplyMe: data.pushReplyMe.bool, pushFavorited: data.pushFavorited.bool)
            },
            completion: completion
        )
    }
}