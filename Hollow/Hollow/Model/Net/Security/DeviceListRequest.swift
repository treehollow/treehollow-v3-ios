//
//  DeviceListRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation

/// The configuration parameter is the user token.
typealias DeviceListRequestConfiguration = String

struct DeviceListRequestResult {
    enum ResultType: Int {
        case success = 0
    }
    
    var type: ResultType
    var devices: [DeviceInformation]
}
