//
//  LogoutRequest.swift
//  Hollow
//
//  Created by aliceinhollow on 6/2/2021.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Alamofire

struct LogoutRequestConfiguration {
    var token: String
    var apiRoot: String
}

struct LogoutRequestResult: Codable {
    var code: Int
}

struct LogoutRequestResultData {
    enum ResultType: Int {
        case success = 0
    }
    
    var result: ResultType
}

/// logout request same as devicetermination
struct LogoutRequest: Request {
    typealias Configuration = LogoutRequestConfiguration
    typealias Result = LogoutRequestResult
    typealias ResultData = LogoutRequestResultData
    typealias Error = DefaultRequestError
    
    var configuration: LogoutRequestConfiguration
    
    init(configuration: LogoutRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (LogoutRequestResultData?, DefaultRequestError?) -> Void) {
        let urlPath =
            self.configuration.apiRoot + "v3/security/logout" + Constants.URLConstant.urlSuffix
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
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let result = try jsonDecoder.decode(Result.self, from: response.data!)
                    if result.code >= 0 {
                        // result code >= 0 valid!
                        let resultData = ResultData(result: ResultData.ResultType(rawValue: result.code)!)
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
                    .other(description: error.errorDescription ?? "Unkown error when performing Logout!"))
            }
            
        }
        
    
    }
    
}

