//
//  View+proposedOverlay.swift
//  Hollow
//
//  Created by liang2kl on 2021/5/29.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func proposedOverlay() -> some View {
        self.modifier(ProposedOverlay())
    }
}

fileprivate struct ProposedOverlay: ViewModifier {
    @State private var showOverlay = false
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: .detailShown)) { _ in
                withAnimation { showOverlay = true }
            }
            .onReceive(NotificationCenter.default.publisher(for: .detailDismissed)) { _ in
                withAnimation { showOverlay = false }
            }
            .overlay(Group {
                if showOverlay {
                    Color.black.opacity(0.2).ignoresSafeArea()
                }
            })
    }
}
