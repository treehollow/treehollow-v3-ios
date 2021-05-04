//
//  GetFrame.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/8.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

/// Get the frame of the view in given coordinate space.
struct GetFrame: ViewModifier {
    @Binding var frame: CGRect
    var handler: ((CGRect) -> Void)?
    var coordinateSpace: CoordinateSpace
    
    init(frame: Binding<CGRect>, coordinateSpace: CoordinateSpace = .global) {
        self._frame = frame
        self.coordinateSpace = coordinateSpace
    }
    
    init(coordinateSpace: CoordinateSpace = .global, handler: @escaping (CGRect) -> Void) {
        self.handler = handler
        self.coordinateSpace = coordinateSpace
        self._frame = .constant(.zero)
    }
    
    func body(content: Content) -> some View {
        content
            .background(GeometryReader { proxy in
                Color.clear.preference(key: ViewFrameKey.self, value: proxy.frame(in: coordinateSpace))
                    .onPreferenceChange(ViewFrameKey.self) { frame in
                        if let handler = handler {
                            handler(frame)
                        } else {
                            self.frame = frame
                        }
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
