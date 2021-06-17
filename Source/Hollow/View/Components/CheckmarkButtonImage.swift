//
//  CheckmarkButtonImage.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/13.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct CheckmarkButtonImage: View {
    var isOn: Bool
    
    var body: some View {
        Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
            .foregroundColor(isOn ? .tint : .uiColor(.systemFill))
            .imageScale(.large)
    }
}
