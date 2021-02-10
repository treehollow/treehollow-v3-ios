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
