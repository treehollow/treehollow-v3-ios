//
//  View+conditionalPadding.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/18.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func conditionalPadding(
        safeAreaInsets: EdgeInsets,
        top: CGFloat? = 0,
        bottom: CGFloat? = 0,
        leading: CGFloat? = 0,
        trailing: CGFloat? = 0) -> some View {
        self
            .padding(.bottom, safeAreaInsets.bottom > 0 ? 0 : bottom)
            .padding(.top, safeAreaInsets.top > 0 ? 0 : top)
            .padding(.leading, safeAreaInsets.leading > 0 ? 0 : leading)
            .padding(.trailing, safeAreaInsets.trailing > 0 ? 0 : trailing)
    }
}
