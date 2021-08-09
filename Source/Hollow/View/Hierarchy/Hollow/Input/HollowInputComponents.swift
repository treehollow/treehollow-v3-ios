//
//  HollowInputComponents.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Introspect

struct HollowInputTextEditor: View {
    
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        TextEditor(text: $text)
            .background(Group { if text == "" {
                Text(placeholder)
                    .foregroundColor(.uiColor(.systemFill))
            }})
    }
}

struct HollowInputAvatar: View {
    var avatarWidth: CGFloat
    var hash: Int
    var body: some View {
        Avatar(
            foregroundColor: .buttonGradient1,
            backgroundColor: .background,
            resolution: 6,
            padding: avatarWidth * 0.1,
            hashValue: hash,
            name: "N",
            options: .forceGraphical
        )

        .frame(width: avatarWidth)
        .fixedSize()
        .clipShape(Circle())
        .overlay(Circle().stroke(lineWidth: 2).foregroundColor(.buttonGradient1))
        .leading()
    }
}
