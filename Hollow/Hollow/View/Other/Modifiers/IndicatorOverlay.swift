//
//  IndicatorOverlay.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/16.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct IndicatorOverlay: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme

    @ScaledMetric(wrappedValue: 16, relativeTo: .body) var fontSize: CGFloat
    @ScaledMetric(wrappedValue: 5, relativeTo: .body) var body5: CGFloat
    @ScaledMetric(wrappedValue: 10, relativeTo: .body) var body10: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, body10)
            .padding(.vertical, body5)
            .background(Color.background)
            .colorScheme(colorScheme == .dark ? .light : .dark)
            .clipShape(Capsule())
            .padding(.top)
            .top()
    }
}
