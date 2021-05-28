//
//  View+stackedBackground.swift
//  Hollow
//
//  Created by liang2kl on 2021/5/28.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func stackedBackground<Background: View>(_ background: Background) -> some View {
        ZStack {
            background
            self
        }
    }
}
