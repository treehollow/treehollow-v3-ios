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
struct DeviceTerminationRequestResult: DefaultRequestResult {
    var code: Int
    var msg: String?
}

enum DeviceTerminationRequestResultData: Int {
    case success = 0
}

struct DeviceTerminationRequest: DefaultRequest {
    
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
        performRequest(
            urlPath: urlPath,
            parameters: parameters,
            headers: headers,
            method: .post,
            resultToResultData: { result in ResultData(rawValue: result.code)},
            completion: completion
        )
    }
}
