//
//  CustomTransitions.swift
//  Hollow
//
//  Created by liang2kl on 2021/5/28.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension AnyTransition {
    static func hide(to anchor: UnitPoint) -> AnyTransition {
        AnyTransition.scale(scale: 0, anchor: anchor).combined(with: .opacity)
    }
    static let hideToBottomTrailing = hide(to: .bottomTrailing)
    static let scaleAndOpacity = AnyTransition.scale.combined(with: .opacity)
}


extension AnyTransition {
    static func invisible(insertion: AnyTransition) -> AnyTransition {
        return .asymmetric(insertion: insertion, removal: .modifier(
            active: InvisibleModifier(pct: 0),
            identity: InvisibleModifier(pct: 1)
        ))
    }
    
    static let floatButton = invisible(insertion: .hideToBottomTrailing)
    
    fileprivate struct InvisibleModifier: AnimatableModifier {
        var pct: Double
        
        var animatableData: Double {
            get { pct }
            set { pct = newValue }
        }
        
        func body(content: Content) -> some View {
            content.opacity(pct == 1.0 ? 1 : 0)
        }
    }

}

