//
//  Data+hexEncodedString.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/4.
//  Copyright © 2021 treehollow. All rights reserved.
//
//  Reference: https://stackoverflow.com/questions/39075043/how-to-convert-data-to-hex-string-in-swift
//

import Foundation

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}
