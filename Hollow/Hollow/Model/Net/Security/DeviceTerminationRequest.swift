//
//  DeviceTerminationRequest.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import Foundation
import Alamofire

/// The request parameter is the UUID of the device.
struct DeviceTerminationRequestConfiguration {
    var deviceUUID: UUID
    var token: String
    var apiRoot: String
}

/// The only result is the code.
//typealias DeviceTerminationRequestResult = DeviceTerminationRequestResultType

/// Result type of device termination.
///
/// Please init with `DeviceTerminationRequestResultType(rawValue: Int)`, and should
/// show error with `nil`, which means receiving negative code.
struct DeviceTerminationRequestResult: Codable {
    var code: Int
    var msg: String?
}

enum DeviceTerminationRequestResultData: Int {
    case success = 0
}

struct DeviceTerminationRequest: Request {
    
    typealias Configuration = DeviceTerminationRequestConfiguration
    typealias Result = DeviceTerminationRequestResult
    typealias ResultData = DeviceTerminationRequestResultData
    typealias Error = DefaultRequestError
    
    var configuration: DeviceTerminationRequestConfiguration
    
    init(configuration: DeviceTerminationRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (DeviceTerminationRequestResultData?, DefaultRequestError?) -> Void) {
        let urlPath =
            self.configuration.apiRoot + "v3/security/devices/terminate" + Constants.URLConstant.urlSuffix
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]
        let parameters = ["device_uuid": self.configuration.deviceUUID]
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
                        var error = DefaultRequestError()
                        error.initbyCode(errorCode: result.code, description: result.msg)
                        completion(nil, error)
                    }
                } catch {
                    completion(nil, DefaultRequestError(errorType: .decodeFailed))
                    return
                }
            case let .failure(error):
                completion(
                    nil,DefaultRequestError(errorType: .other(description: error.localizedDescription)))
            }
        }
    }
}
