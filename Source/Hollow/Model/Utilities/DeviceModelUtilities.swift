//
//  DeviceModelUtilities.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/15.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

struct DeviceModelUtilities {
    static var modelIdentifier: String {
        #if targetEnvironment(simulator)
        return ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? ""
        #else
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        print(machineMirror.children)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
        #endif
    }
}
