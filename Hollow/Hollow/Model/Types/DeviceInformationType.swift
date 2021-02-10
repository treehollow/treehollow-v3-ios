//
//  DeviceInformationType.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import Foundation

/// Information of a logged-in device.
/*
    "device_uuid": "2a6f855e-8f8d-4795-818b-50402dbcc60f",
    "login_date": "1926-08-17",
    "device_info": "HUAWEI P40, Android 11",
    "device_type": 0(0 for Web, 1 for Android, 2 for iOS)
 */
struct DeviceInformationType: Codable {
    /// Device type.
    enum DeviceType: Int, CustomStringConvertible , Codable {
        case web = 0
        case android = 1
        case ios = 2
        case unknown = -1
        
        var description: String {
            switch self {
            // TODO: Localization
            case .web: return "Web"
            case .android: return "Android"
            case .ios: return "iOS"
            case .unknown: return "Unknown Device"
            }
        }
    }
    /// UUID of the device.
    // FIXME: convertFromSnakeCase
    var deviceUUID: UUID
    /// Login date of the device.
    var loginDate: Date
    /// Device desciption.
    var deviceInfo: String
    /// Device type.
    var deviceType: DeviceType
}
