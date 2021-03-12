//
//  HollowInputComponents.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct HollowInputTextEditor: View {
    @Binding var text: String
    @Binding var editorEditing: Bool
    var placeholder: String
    var startEditingOnAppear = false
    var receiveCallback = false
    
    @ScaledMetric(wrappedValue: ViewConstants.plainButtonFontSize) var buttonFontSize: CGFloat
    
    var body: some View {
        CustomTextEditor(text: $text, editing: $editorEditing, receiveCallback: receiveCallback, editOnAppear: startEditingOnAppear, modifiers: { $0 })
            .overlayDoneButtonAndLimit(
                editing: $editorEditing,
                textCount: text.count,
                limit: 10000,
                buttonFontSize: buttonFontSize
            )
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
            hashValue: hash
        )

        .frame(width: avatarWidth)
        .fixedSize()
        .clipShape(Circle())
        .overlay(Circle().stroke(lineWidth: 2).foregroundColor(.buttonGradient1))
        .leading()
    }
}
