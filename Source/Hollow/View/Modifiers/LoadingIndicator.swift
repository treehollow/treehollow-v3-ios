//
//  LoadingIndicator.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/9.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct LoadingIndicator: ViewModifier {
    var isLoading: Bool
    var disableWhenLoading: Bool = false
    
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .overlay(
                Group { if isLoading {
                    LoadingLabel(foregroundColor: .white)
                        .modifier(IndicatorOverlay())
                }}
            )
            .disabled(isLoading && disableWhenLoading)
    }
}
