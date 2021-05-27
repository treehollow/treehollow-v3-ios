//
//  MyTextField.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/30.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct MyTextField<Content>: View where Content: View {
    @Binding var text: String
    var placeHolder: String? = nil
    var title: String?
    var footer: String? = nil
    var isSecureContent = false
    var backgroundColor: Color = .hollowCardBackground
    var disabled = false
    var content: (() -> Content)? = nil

    var body: some View {
        VStack(alignment: .leading) {
            if let title = title {
                Text(title.uppercased())
                    .dynamicFont(size: 14, weight: .medium)
                    .foregroundColor(.hollowContentText)
            }
            HStack(spacing: 0) {
                Group {
                    if isSecureContent {
                        SecureField(placeHolder ?? "", text: $text)
                    } else {
                        TextField(placeHolder ?? "", text: $text)
                    }
                }
                .labelsHidden()
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .dynamicFont(size: 16)
                .foregroundColor(disabled ? .secondary : nil)
                .disabled(disabled)
                Spacer()
                if let content = content {
                    content()
                }
            }
            .padding(10)
            .padding(.horizontal, 6)
            .background(backgroundColor)
            .roundedCorner(10)
            
            if let footer = footer, footer != "" {
                Text(footer)
                    .dynamicFont(size: 12)
                    .foregroundColor(.secondary)
            }
        }
    }
}
