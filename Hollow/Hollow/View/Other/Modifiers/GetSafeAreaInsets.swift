//
//  GetSafeAreaInsets.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/18.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct GetSafeAreaInsets: ViewModifier {
    @Binding var insets: EdgeInsets
    
    func body(content: Content) -> some View {
        content
            .background(GeometryReader { geometry in
                Color.clear.preference(key: ViewSafeAreaInsetsKey.self, value: geometry.safeAreaInsets)
                    .onPreferenceChange(ViewSafeAreaInsetsKey.self) { value in
                        insets = value
                    }
            })

    }
}

fileprivate struct ViewSafeAreaInsetsKey: PreferenceKey {
    static var defaultValue: EdgeInsets = .init()

    static func reduce(value: inout EdgeInsets, nextValue: () -> EdgeInsets) {
        value = nextValue()
    }
}
