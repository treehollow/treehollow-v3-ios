//
//  View+roundedCorner.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/5.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func roundedCorner(_ radius: CGFloat) -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}
