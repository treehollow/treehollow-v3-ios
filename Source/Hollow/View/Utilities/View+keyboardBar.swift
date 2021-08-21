//
//  View+keyboardBar.swift
//  View+keyboardBar
//
//  Created by liang2kl on 2021/8/9.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder func keyboardBar() -> some View {
        if #available(iOS 15.0, *) {
            self.toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("INPUTVIEW_TEXT_EDITOR_DONE_BUTTON", action: hideKeyboard)
                        .trailing()
                        .accentColor(.tint)
                }
            }
        } else {
            // FIXME
            self.toolbar {
                Button("INPUTVIEW_TEXT_EDITOR_DONE_BUTTON", action: hideKeyboard)
                    .trailing()
                    .accentColor(.tint)
            }
        }
    }
}
