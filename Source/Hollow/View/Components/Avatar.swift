//
//  Avatar.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/15.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

struct Avatar: View {
    var colors: [Color]
    var paddingColor: Color
    var resolution: Int
    var padding: CGFloat
    var name: String
    var options: Options
    @Default(.usingSimpleAvatar) var usingSimpleAvatar
    
    private var showGraphical: Bool {
        if options.contains(.forceGraphical) { return true }
        if options.contains(.forceTextual) { return false }
        return !usingSimpleAvatar
    }
    
    init(foregroundColor: Color, backgroundColor: Color, resolution: Int, padding: CGFloat, hashValue: Int, name: String, options: Options = []) {
        self.paddingColor = foregroundColor
        self.colors = AvatarGenerator.colorData(foregroundColor: foregroundColor, backgroundColor: backgroundColor, resolution: resolution, hashValue: hashValue)
        self.resolution = resolution
        self.padding = padding
        self.name = name
        self.options = options
    }
    
    var body: some View {
        if showGraphical {
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
            
        } else {
            ZStack {
                Rectangle()
                    .foregroundColor(paddingColor)
                Text(name)
                    .fontWeight(.heavy)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
            }
            .aspectRatio(1, contentMode: .fill)
        }
    }
}

extension Avatar {
    struct Options: OptionSet {
        let rawValue: Int
        static let forceGraphical = Options(rawValue: 1 << 1)
        static let forceTextual = Options(rawValue: 1 << 2)
    }
}
