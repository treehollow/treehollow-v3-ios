//
//  ImageButtonModifier.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/2.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct ImageButtonModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.hollowContentText)
            .dynamicFont(size: 20, weight: .medium)
    }
}
