//
//  HollowStarButtonStyle.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct HollowButtonStyle: ViewModifier {
    @ScaledMetric(wrappedValue: 16, relativeTo: .body) var body16: CGFloat
    @Environment(\.isEnabled) var enabled
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: body16, weight: .semibold, design: .rounded))
            .opacity(enabled ? 1 : 0.5)
    }
}
