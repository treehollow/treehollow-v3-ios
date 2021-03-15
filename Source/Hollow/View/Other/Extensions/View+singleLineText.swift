//
//  View+singleLineText.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/15.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func singleLineText(minScaleFactor: CGFloat = 0.5) -> some View {
        self
            .minimumScaleFactor(minScaleFactor)
            .lineLimit(1)
    }
}
