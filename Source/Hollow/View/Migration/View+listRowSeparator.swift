//
//  View+listRowSeparator.swift
//  View+listRowSeparator
//
//  Created by liang2kl on 2021/8/21.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder func listRowSeparator(hidden: Bool = true) -> some View {
        if #available(iOS 15.0, *) {
            self.listRowSeparator(hidden ? .hidden : .visible, edges: .all)
        } else {
            self
        }
    }
}
