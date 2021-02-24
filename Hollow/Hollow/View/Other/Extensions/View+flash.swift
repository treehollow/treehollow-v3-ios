//
//  View+flash.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/24.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder func flash(appear: Bool) -> some View {
        if appear {
            self.modifier(Flash())
        } else {
            self
        }
    }
}

fileprivate struct Flash: ViewModifier {
    @State private var flash: Bool = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Color.uiColor(flash ? .systemFill : .tertiarySystemFill)
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                            flash.toggle()
                        }
                    }
            )
        
    }
}
