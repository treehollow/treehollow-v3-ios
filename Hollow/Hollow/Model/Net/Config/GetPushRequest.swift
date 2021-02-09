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
                    if result["code"].int! >= 0 {
                        // result code >= 0 valid!
                        let resultData = ResultData.init(
                            pushSystemMsg: result["data"]["push_system_msg"].bool!,
                            pushReplyMe: result["data"]["push_reply_me"].bool!,
                            pushFavorited: result["data"]["push_favorited"].bool!)
                        completion(resultData, nil)
                    } else {
                        // invalid response
                        var error = DefaultRequestError()
                        error.initbyCode(errorCode: result["code"].int!, description: result["msg"].string)
                        completion(nil, error)
                    }
                } catch {
                    completion(nil, DefaultRequestError(errorType: .decodeFailed))
                    return
                }
            case let .failure(error):
                completion(nil,DefaultRequestError(errorType: .other(description: error.localizedDescription)))
            }
        }
    }
    
}
