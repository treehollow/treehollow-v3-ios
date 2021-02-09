//
//  GetPushRequest.swift
//  Hollow
//
//  Created by aliceinhollow on 7/2/2021.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct GetPushRequestConfiguration {
    var apiRoot: String
    var token: String
}

typealias GetPushRequestResultData = PushNotificationType

struct GetPushRequest: Request {
   
    typealias Configuration = GetPushRequestConfiguration
    typealias Result = GetPushRequestResultData
    typealias ResultData = GetPushRequestResultData
    typealias Error = DefaultRequestError
    var configuration: GetPushRequestConfiguration
    
    init(configuration: GetPushRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (GetPushRequestResultData?, DefaultRequestError?) -> Void) {
        let urlPath =
            self.configuration.apiRoot + "v3/security/get_push" + Constants.URLConstant.urlSuffix
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]
        
        AF.request(
            urlPath,
            method: .post,
            headers: headers
        ).validate().responseJSON { response in
            switch response.result {
            case .success:
                do {
                    let result = try JSON(data: response.data!)
                    guard let code = result["code"].int else {
                        completion(nil, .unknownBackend)
                        return
                    }
                    if code >= 0 {
                        // result code >= 0 valid!
                        guard let pushSystemMsg = result["data"]["push_system_msg"].bool,
                              let pushReplyMe = result["data"]["push_reply_me"].bool,
                              let pushFavorited = result["data"]["push_favorited"].bool else {
                            completion(nil, .unknownBackend)
                            return
                        }
                        let resultData = ResultData.init(
                            pushSystemMsg: pushSystemMsg,
                            pushReplyMe: pushReplyMe,
                            pushFavorited: pushFavorited)
                        completion(resultData, nil)
                    } else {
                        // invalid response
                        completion(nil, .init(errorCode: code, description: result["msg"].string ?? "Unknown backend error."))
                    }
                } catch {
                    completion(nil, .decodeFailed)
                    return
                }
            case let .failure(error):
                completion(nil, .other(description: error.localizedDescription))
            }
        }
    }
    
}
