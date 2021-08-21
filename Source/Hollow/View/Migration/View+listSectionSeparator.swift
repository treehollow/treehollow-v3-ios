//
//  View+listSectionSeparator.swift
//  View+listSectionSeparator
//
//  Created by liang2kl on 2021/8/21.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder func listSectionSeparator(hidden: Bool = true) -> some View {
        if #available(iOS 15.0, *) {
            self.listSectionSeparator(hidden ? .hidden : .visible, edges: .all)
        } else {
            self
        }
    }
}
