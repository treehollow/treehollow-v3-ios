//
//  View+keyboardShortCut.swift
//  Hollow
//
//  Created by liang2kl on 2021/5/14.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func keyboardShortcut(_ key: KeyEquivalent, action: @escaping () -> Void) -> some View {
        return self
            .overlay(Button("", action: action).keyboardShortcut(key).opacity(0))
    }
}
