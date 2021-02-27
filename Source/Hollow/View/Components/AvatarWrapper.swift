//
//  AvatarWrapper.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/15.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import AvatarX

struct AvatarWrapper<HashableValue>: View where HashableValue: Hashable {
    var colors: [Color]
    var resolution: Int
    var symmetric: Bool = true
    var padding: CGFloat = 0
    var value: HashableValue
    
    var body: some View {
        Avatar(
            configuration: AvatarConfiguration(
                colors: colors,
                resolution: resolution,
                symmetric: symmetric
            ),
            value: value
        )
        .padding(padding)
        .background(colors.count >= 1 ? colors[0] : nil)
    }
}
