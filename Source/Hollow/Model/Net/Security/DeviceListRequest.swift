//
//  DeviceListRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation
import Alamofire

struct DeviceListRequestConfiguration {
    var token: String
    var apiRoot: [String]
}

struct DeviceListRequestResult: DefaultRequestResult {
    struct DeviceListResult: Codable {
        var deviceUuid: String
        var loginDate: String
        var deviceInfo: String
        var deviceType: Int
    }
    var code: Int
    var msg: String?
    var data: [DeviceListResult]?
    var thisDevice: String?
}

struct DeviceListRequestResultData: Codable {
    var devices: [DeviceInformationType]
    var thisDeviceUUID: String
}

struct DeviceListRequest: DefaultRequest {
    
    typealias Configuration = DeviceListRequestConfiguration
    typealias Result = DeviceListRequestResult
    typealias ResultData = DeviceListRequestResultData
    typealias Error = DefaultRequestError
    
    var configuration: DeviceListRequestConfiguration
    
    init(configuration: DeviceListRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (ResultData?, Error?) -> Void) {
        let urlPath = "v3/security/devices/list" + Constants.Net.urlSuffix
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
                guard let data = result.data, let thisDeviceUUIDString = result.thisDevice else { return nil }
                var devices = [DeviceInformationType]()
                for device in data {
                    devices.append(
                        DeviceInformationType(
                            deviceUUID: device.deviceUuid,
                            loginDate: device.loginDate.toDate() ?? Date(),
                            deviceInfo: device.deviceInfo,
                            deviceType: DeviceInformationType.DeviceType(
                                rawValue: device.deviceType) ?? DeviceInformationType.DeviceType.unknown
                        )
                    )
                }
                return ResultData(devices: devices, thisDeviceUUID: thisDeviceUUIDString)
            },
            completion: completion
        )
    }
}
