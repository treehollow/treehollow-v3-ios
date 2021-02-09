//
//  DeviceListRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation
import Alamofire
import SwiftyJSON

/// The configuration parameter is the user token.
struct DeviceListRequestConfiguration {
    var token: String
    var apiRoot: String
}

struct DeviceListRequestResultData {
    var devices: [DeviceInformationType]
    var thisDeviceUUID: UUID
}

struct DeviceListRequest: Request {
    
    typealias Configuration = DeviceListRequestConfiguration
    typealias Result = DeviceListRequestResultData
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
            method: .get,
            headers: headers
        ).validate().responseJSON { response in
            switch response.result {
            case .success:
                do {
                    let result = try JSON.init(data: response.data!)
                    guard let code = result["code"].int else {
                        completion(nil, .unknownBackend)
                        return
                    }
                    if code >= 0 {
                        var deviceList = [DeviceInformationType]()
                        for (_, subJson): (String, JSON) in result["data"] {
                            guard let deviceUUIDString = subJson["device_uuid"].string,
                                  let deviceUUID = UUID(uuidString: deviceUUIDString),
                                  let loginDate = subJson["login_date"].string?.toDate(),
                                  let deviceInfo = subJson["device_info"].string,
                                  let deviceTypeRawValue = subJson["device_type"].int,
                                  let deviceType = DeviceInformationType.DeviceType(rawValue: deviceTypeRawValue) else {
                                completion(nil, .unknownBackend)
                                return
                            }
                            let subResult = DeviceInformationType(
                                deviceUUID: deviceUUID,
                                loginDate: loginDate,
                                deviceInfo: deviceInfo,
                                deviceType: deviceType
                            )
                            deviceList.append(subResult)
                        }
                        guard let thisDeviceUUIDString = result["this_device"].string,
                              let thisDeviceUUID = UUID(uuidString: thisDeviceUUIDString) else {
                            completion(nil, .unknownBackend)
                            return
                        }
                        let resultData = ResultData(devices: deviceList, thisDeviceUUID: thisDeviceUUID)
                        completion(resultData, nil)
                    } else {
                        // invalid response
                        completion(nil, .init(errorCode: code, description: result["msg"].string ?? "Unknown backend error."))
                    }
                } catch {
                    completion(nil, .decodeFailed)
                    return
                }
            case .failure(let error):
                completion(nil, .other(description: error.localizedDescription))}
        }
    }
}
