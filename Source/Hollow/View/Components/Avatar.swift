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
    @Default(.usingSimpleAvatar) var usingSimpleAvatar
    @Default(.usingOffscreenRender) var usingOffscreenRender
    
    init(foregroundColor: Color, backgroundColor: Color, resolution: Int, padding: CGFloat, hashValue: Int, name: String) {
        self.paddingColor = foregroundColor
        self.colors = AvatarGenerator.colorData(foregroundColor: foregroundColor, backgroundColor: backgroundColor, resolution: resolution, hashValue: hashValue)
        self.resolution = resolution
        self.padding = padding
        self.name = name
    }
    
    var body: some View {
        if !usingSimpleAvatar {
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
            .conditionalDrawingGroup(usingOffscreenRender)
            .aspectRatio(1, contentMode: .fill)
            .padding(padding)
            .background(paddingColor)
            
        } else {
            ZStack {
                Rectangle()
                    .foregroundColor(paddingColor)
                Text(String(name.first ?? " "))
                    .fontWeight(.heavy)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.white)
            }
            .aspectRatio(1, contentMode: .fill)
        }
    }
}

private extension View {
    @ViewBuilder func conditionalDrawingGroup(_ apply: Bool) -> some View {
        if apply { self.drawingGroup() }
        else { self }
    }
}
