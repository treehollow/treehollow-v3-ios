//
//  BarImageButton.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/11.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct BarButton: View {
    var action: () -> Void
    var systemImageName: String

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImageName)
                .modifier(ImageButtonModifier())
        }
    }
}
