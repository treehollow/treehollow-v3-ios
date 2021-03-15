//
//  MyButtonDefaultStyle.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/13.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct MyButtonDefaultStyle: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .dynamicFont(size: 14, weight: .bold)
            .foregroundColor(.white)
    }
}
