//
//  View+makeButton.swift
//  Hollow
//
//  Created by liang2kl on 2021/5/16.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func makeButton(action: @escaping () -> Void) -> some View {
        Button(action: action, label: { self })
    }
}
