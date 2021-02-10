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
    struct DeviceListResult: Codable{
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

struct DeviceListRequestResultData {
    var devices: [DeviceInformationType]
    var thisDeviceUUID: UUID
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
        let urlPath =
            self.configuration.apiRoot + "v3/security/devices/list" + Constants.URLConstant.urlSuffix
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]
        let parameters = ["": ""]
        performRequest(
            urlPath: urlPath,
            parameters: parameters,
            headers: headers,
            method: .get,
            resultToResultData: {result in
                guard let data = result.data,let thisDeviceUUIDString = result.thisDevice else {return nil}
                let thisDeviceUUID = UUID.init(uuidString: thisDeviceUUIDString)
                var devices = [] as [DeviceInformationType]
                for device in data {
                    devices.append(
                        DeviceInformationType(
                            deviceUUID: UUID.init(uuidString: device.deviceUuid) ?? UUID(),
                            loginDate: device.loginDate.toDate() ?? Date(),
                            deviceInfo: device.deviceInfo,
                            deviceType: DeviceInformationType.DeviceType(
                                rawValue: device.deviceType) ?? DeviceInformationType.DeviceType.unknown
                        )
                    )
                }
                // use thisDeviceUUID! because UUID must be uuid
                    return ResultData(devices: devices, thisDeviceUUID: thisDeviceUUID ?? UUID())
            },
            completion: completion
        )
    }
}
