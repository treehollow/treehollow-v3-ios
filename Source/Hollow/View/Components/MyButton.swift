//
//  MyButton.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/27.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

fileprivate let defaultButtonRadius: CGFloat = 8
fileprivate let defaultGradient: LinearGradient = .vertical(gradient: .button)

struct MyButton<Content>: View where Content: View {
    var action: () -> Void
    var gradient: LinearGradient = defaultGradient
    var transitionAnimation: Animation? = nil
    @ScaledMetric var cornerRadius: CGFloat = defaultButtonRadius
    var content: () -> Content
    
    @Environment(\.isEnabled) var enabled
    var body: some View {
        Button(action: action) {
            content()
                .padding(.horizontal, 13)
                .padding(.vertical, 7)
                .background(gradient)
                .opacity(enabled ? 1 : 0.5)
                .cornerRadius(cornerRadius)
//                .animation(transitionAnimation)
        }
    }
}

extension View {
    func defaultButtonStyle() -> some View {
        return self
            .padding(.horizontal, 13)
            .padding(.vertical, 7)
            .background(defaultGradient)
            .cornerRadius(defaultButtonRadius)
    }
}
