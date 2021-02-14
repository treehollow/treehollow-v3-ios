//
//  AvatarGenerator.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/14.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct AvatarGenerator<HashableValue> where HashableValue: Hashable {
    var configuration: AvatarConfiguration
    var value: HashableValue
    
    func generateAvatarData() -> [Color] {
        let hashValue = value.hashValue
        let digits = String(hashValue).compactMap({ $0.wholeNumberValue })
        var data = [Color]()
        for i in 0..<configuration.resolution * configuration.resolution {
            let colorIndex = digits[i % digits.count]
            let color = configuration.colors[colorIndex % configuration.colors.count]
            data.append(color)
        }
        return data
    }
}

public struct AvatarConfiguration {
    public var colors: [Color]
    var resolution: Int
}
