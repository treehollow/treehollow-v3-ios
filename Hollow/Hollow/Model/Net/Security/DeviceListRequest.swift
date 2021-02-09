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
                    //debugPrint(response)
                    if result["code"].int! >= 0 {
                        var deviceList = [DeviceInformationType]()
                        for (_,subJson):(String, JSON) in result["data"] {
                            let subResult = DeviceInformationType.init(
                                deviceUUID: UUID.init(uuidString: subJson["device_uuid"].string!)!,
                                loginDate: subJson["login_date"].string!.toDate()!,
                                deviceInfo: subJson["device_info"].string!,
                                deviceType: DeviceInformationType.DeviceType.init(rawValue: subJson["device_type"].int!)!)
                            deviceList.append(subResult)
                        }
                        let resultData = ResultData.init(devices: deviceList, thisDeviceUUID: UUID.init(uuidString: result["this_device"].string!)!)
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
            case .failure(let error):
                completion(
                    nil,DefaultRequestError(errorType: .other(description: error.localizedDescription)))
            }
        }
    }
}
