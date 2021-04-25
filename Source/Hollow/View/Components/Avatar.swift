//
//  Avatar.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/15.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct Avatar: View {
    var colors: [Color]
    var paddingColor: Color
    var resolution: Int
    var padding: CGFloat
    
    init(foregroundColor: Color, backgroundColor: Color, resolution: Int, padding: CGFloat, hashValue: Int) {
        self.paddingColor = foregroundColor
        self.colors = AvatarGenerator.colorData(foregroundColor: foregroundColor, backgroundColor: backgroundColor, resolution: resolution, hashValue: hashValue)
        self.resolution = resolution
        self.padding = padding
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<resolution) { x in
                HStack(spacing: 0) {
                    ForEach(0..<resolution) { y in
                        let index = x * resolution + y
                        Rectangle()
                            .foregroundColor(colors[index])
                            .aspectRatio(1, contentMode: .fill)
                    }
                }
            }
        }
        .drawingGroup()
        .aspectRatio(1, contentMode: .fill)
        .padding(padding)
        .background(paddingColor)
    }
}
