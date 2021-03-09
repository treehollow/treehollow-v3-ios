//
//  AvatarGenerator.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/9.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct AvatarGenerator {
    static func colorData(foregroundColor: Color, backgroundColor: Color, resolution: Int, hashValue: Int) -> [Color] {
        var data = [Color](repeating: backgroundColor, count: resolution * resolution)
        for i in 0..<resolution * resolution / 2 {
            let x = i % (resolution / 2)
            let y = i / (resolution / 2)
            if hashValue & (1 << i) != 0 {
                data[y * resolution + x] = foregroundColor
                data[y * resolution + resolution - x - 1] = foregroundColor
            }
        }
        return data
    }
    
    static func hash(postId: Int, name: String) -> Int {
        let int32PostId = Int32(postId)
        var hash = Int32(5381)
        for _ in 0..<20 {
            hash &+= (hash << 5) + int32PostId
        }
        for character in name {
            hash &+= (hash << 5) + Int32(character.asciiValue ?? 0)
        }
        hash = (hash >> 8) ^ hash
        return Int(hash)
    }
    
    static func colorIndex(hash: Int) -> Int {
        let colors = ViewConstants.avatarTintColors
        let newValue = Int(Int32(hash) &>> 18)
        var colorIndex = newValue % colors.count
        print(colorIndex)
        if colorIndex < 0 {
            colorIndex += colors.count
        }
        return colorIndex
    }
}
