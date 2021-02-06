//
//  DeviceTerminationRequest.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import Foundation

/// The request parameter is the UUID of the device.
typealias DeviceTerminationRequestConfiguration = UUID

/// The only result is the code.
typealias DeviceTerminationRequestResult = DeviceTerminationRequestResultType

/// Result type of device termination.
///
/// Please init with `DeviceTerminationRequestResultType(rawValue: Int)`, and should
/// show error with `nil`, which means receiving negative code.
enum DeviceTerminationRequestResultType: Int {
    case success = 0
}
