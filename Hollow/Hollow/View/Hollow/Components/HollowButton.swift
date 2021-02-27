//
//  HollowStarButton.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct HollowButton: View {
    var number: Int

    var action: () -> Void
    var systemImageName: String
    
    @ScaledMetric(wrappedValue: 16, relativeTo: .body) var body16: CGFloat
    @Environment(\.isEnabled) var enabled
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 3) {
                Text("\(number.string)")
                Image(systemName: systemImageName)
            }
            .font(.system(size: body16, weight: .semibold, design: .rounded))
            .opacity(enabled ? 1 : 0.5)
            .padding(5)
        }
    }
}
