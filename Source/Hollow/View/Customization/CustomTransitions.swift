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
}
