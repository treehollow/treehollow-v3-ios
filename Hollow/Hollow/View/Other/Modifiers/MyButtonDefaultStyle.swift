//
//  MyButtonDefaultStyle.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/13.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct MyButtonDefaultStyle: ViewModifier {
    @ScaledMetric var fontSize: CGFloat = 14
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: fontSize, weight: .bold))
            .foregroundColor(.white)
    }
}
