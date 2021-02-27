//
//  View+revertColorScheme.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func revertColorScheme() -> some View {
        return self
            .modifier(RevertColorScheme())
    }
}

fileprivate struct RevertColorScheme: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .colorScheme(colorScheme == .dark ? .light : .dark)
    }
}
