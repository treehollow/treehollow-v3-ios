//
//  ImageButtonModifier.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/2.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct ImageButtonModifier: ViewModifier {
    @ScaledMetric var fontSize: CGFloat = 20
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.hollowContentText)
            .font(.system(size: fontSize, weight: .medium))
    }
}
