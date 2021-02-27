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
/*
 "code":0,
 "data": [{
 "device_uuid": "2a6f855e-8f8d-4795-818b-50402dbcc60f",
 "login_date": "1926-08-17",
 "device_info": "HUAWEI P40, Android 11",
 "device_type": 0(0 for Web, 1 for Android, 2 for iOS)
 },..],
 "this_device": "uuid"
 */
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
        let urlPath = "v3/security/devices/list" + Constants.URLConstant.urlSuffix
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]
        performRequest(
            urlBase: self.configuration.apiRoot,
            urlPath: urlPath,
            headers: headers,
            method: .get,
            resultToResultData: { result in
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
