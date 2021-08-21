//
//  View+bottomSafeAreaInset.swift
//  View+bottomSafeAreaInset
//
//  Created by liang2kl on 2021/8/21.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder func bottomSafeAreaInset<Content: View>(content: @escaping () -> Content) -> some View {
        if #available(iOS 15.0, *) {
            self.safeAreaInset(edge: .bottom) {
                content()
            }
        } else {
            self.overlay(
                content().bottom()
            )
        }
    }
}
