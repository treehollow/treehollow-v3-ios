//
//  Font+dynamic.swift
//  Hollow
//
//  Created by 梁业升 on 2021/2/5.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension Font {
    /// Apply a dynamic system font to adjust font size according to the setting.
    static func dynamic(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
        // FIXME: The text cannot be scaled immediately after changing the scaling
        // unless the view is redrawn.
        return Font.system(size: size.dynamic, weight: weight, design: design)
    }
}
