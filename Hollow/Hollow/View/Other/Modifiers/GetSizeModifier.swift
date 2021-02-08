//
//  GetSizeModifier.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/8.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

/// Get the size of the view in given coordinate space.
///
/// Known issues:
/// - not working on stacks
struct GetSizeModifier: ViewModifier {
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        content
            .background(GeometryReader { geometry in
                Color.clear.preference(key: ViewSizeKey.self, value: geometry.size)
                    .onPreferenceChange(ViewSizeKey.self) { value in
                        size = value
                    }
            })
    }
}

fileprivate struct ViewSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
