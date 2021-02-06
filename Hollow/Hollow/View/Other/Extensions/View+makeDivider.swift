//
//  View+makeDivider.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/27.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func makeDivider(height: CGFloat = 1) -> some View {
        return self.frame(height: height)
    }
}
