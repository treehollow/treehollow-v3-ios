//
//  DeviceListRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation
import Alamofire

/// The configuration parameter is the user token.
struct DeviceListRequestConfiguration {
    var token: String
    var apiRoot: String
}

struct DeviceListRequestResultData {
    enum ResultType: Int {
        case success = 0
    }
    
    var result: ResultType
    var devices: [DeviceInformation]
}

struct DeviceListRequestResult: Codable {
    var code: Int
    var data: [DeviceInformation]
    var msg: String?
}

struct DeviceListRequest: Request {
    
    typealias Configuration = DeviceListRequestConfiguration
    typealias Result = DeviceListRequestResult
    typealias ResultData = DeviceListRequestResultData
    typealias Error = DefaultRequestError
    
    var configuration: DeviceListRequestConfiguration
    
    init(configuration: DeviceListRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (ResultData?, Error?) -> Void) {
        let urlPath =
            self.configuration.apiRoot + "v3/security/devices/list" + Constants.URLConstant.urlSuffix
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
                    debugPrint(response)
                    let result = try jsonDecoder.decode(Result.self, from: response.data!)
                    if result.code >= 0 {
                        let resultData = ResultData(result: ResultData.ResultType(rawValue: result.code)!, devices: result.data)
                        completion(resultData, nil)
                    } else {
                        // invalid response
                        completion(nil,
                                   .other(description: result.msg ?? "error code from backend: \(result.code)"))
                    }
                } catch {
                    completion(nil, .decodeFailed)
                    return
                }
            case .failure(let error):
                completion(
                    nil,
                    .other(
                        description: error.errorDescription ?? "Unkown error when performing DeviceListRequest!"))
            }
        }
    }
}
