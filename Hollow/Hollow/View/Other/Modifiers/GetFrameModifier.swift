//
//  GetFrameModifier.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/8.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

/// Get the frame of the view in given coordinate space.
struct GetFrameModifier: ViewModifier {
    @Binding var frame: CGRect
    var coordinateSpace: CoordinateSpace = .global
    func body(content: Content) -> some View {
        content
            .background(GeometryReader { proxy in
                Color.clear.preference(key: ViewFrameKey.self, value: proxy.frame(in: coordinateSpace))
                    .onPreferenceChange(ViewFrameKey.self) { frame in
                        self.frame = frame
                    }
            })
    }
}

fileprivate struct ViewFrameKey: PreferenceKey {
    typealias Value = CGRect
    
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
