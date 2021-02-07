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
            switch response.result{
            case .success:
                do {
                    let result = try JSON(data: response.data!)
                    if result["code"].int! >= 0 {
                        // result code >= 0 valid!
                        let resultData = ResultData.init(
                            pushSystemMsg: result["data"]["push_system_msg"].int! == 1 ? true : false,
                            pushReplyMe: result["data"]["push_reply_me"].int! == 1 ? true : false,
                            pushFavorited: result["data"]["push_favorited"].int! == 1 ? true : false)
                        completion(resultData, nil)
                    } else {
                        // invalid response
                        completion(
                            nil, .other(description: "Received error code from backend: \(result["code"].string!)."))
                    }
                } catch {
                    completion(nil, .decodeFailed)
                    return
                }
            case let .failure(error):
                completion(
                    nil,
                    .other(description: error.errorDescription ?? "Unkown error when performing GetPushRequest!"))
            }
        }
    }
    
}
