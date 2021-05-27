//
//  View+dynamicFont.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/11.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func dynamicFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        self.modifier(DynamicFont(size: size, weight: weight, design: design))
    }
}

fileprivate struct DynamicFont: ViewModifier {
    @ScaledMetric var size: CGFloat
    var weight: Font.Weight
    var design: Font.Design
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: weight, design: design))
    }
}
