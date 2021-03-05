//
//  View+defaultBlurBackground.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/4.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func defaultBlurBackground(hasPost: Bool) -> some View {
        self.modifier(DefaultBlurBackground(hasPost: hasPost))
    }
}

fileprivate struct DefaultBlurBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let hasPost: Bool
    
    func body(content: Content) -> some View {
        content
            // Background color
            .background(
                Color.background
                    .opacity(hasPost && colorScheme == .dark ? 1 : 0.4)
                    .edgesIgnoringSafeArea(.all)
            )
            // Blur background
            .blurBackground()
    }
}
