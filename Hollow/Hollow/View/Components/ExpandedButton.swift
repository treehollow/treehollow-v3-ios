//
//  ExpandedButton.swift
//  Hollow
//
//  Created by 梁业升 on 2021/2/4.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct ExpandedButton: View {
    let action: () -> Void
    var gradient: LinearGradient = .vertical(gradient: .button)
    var transitionAnimation: Animation? = nil
    var text: String
    var customView: AnyView? = nil
    var body: some View {
        MyButton(action: action,
                 gradient: gradient,
                 transitionAnimation: .default,
                 cornerRadius: 12) {
            HStack {
                Text(text)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(8)
                    .horizontalCenter()
                customView
            }
        }
    }
}
