//
//  DeviceInformationType.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import Foundation

/// Information of a logged-in device.
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
            case .unknown: return "Unknown"
            }
        }
    }
    /// UUID of the device.
    var deviceUUID: String
    /// Login date of the device.
    var loginDate: Date
    /// Device desciption.
    var deviceInfo: String
    /// Device type.
    var deviceType: DeviceType
}
