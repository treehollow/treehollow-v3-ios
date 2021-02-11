//
//  MyButton.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/27.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct MyButton<Content>: View where Content: View {
    var action: () -> Void
    var gradient: LinearGradient = .vertical(gradient: .button)
    var transitionAnimation: Animation? = nil
    @ScaledMetric var cornerRadius: CGFloat = 8
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
                .animation(transitionAnimation)
        }
    }
}
