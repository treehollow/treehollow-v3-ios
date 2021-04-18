//
//  IndicatorOverlay.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/16.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct IndicatorOverlay: ViewModifier {
    
    @ScaledMetric(wrappedValue: 5, relativeTo: .body) var body5: CGFloat
    @ScaledMetric(wrappedValue: 10, relativeTo: .body) var body10: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, body10)
            .padding(.vertical, body5)
            .background(Color.hollowContentVoteGradient1)
            .clipShape(Capsule())
            .padding(.top)
            .top()
    }
}
