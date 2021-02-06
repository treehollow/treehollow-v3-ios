//
//  DeviceInformation.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import Foundation

/// Information of a logged-in device.
struct DeviceInformation: Codable {
    /// Device type.
    enum DeviceType: Int,Codable {
        case web = 0
        case android = 1
        case ios = 2
    }
    /// UUID of the device.
    // FIXME: convertFromSnakeCase
    var deviceUuid: UUID
    /// Login date of the device.
    var loginDate: Date
    /// Device desciption.
    var deviceInfo: String
    /// Device type.
    var deviceType: DeviceType
}
