//
//  DeviceInformation.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import Foundation

/// Information of a logged-in device.
struct DeviceInformation {
    /// Device type.
    enum DeviceType: Int {
        case web = 0
        case android = 1
        case ios = 2
    }
    /// UUID of the device.
    var uuid: UUID
    /// Login date of the device.
    var loginDate: Date
    /// Device desciption.
    var deviceInfo: String
    /// Device type.
    var deviceType: DeviceType
}
