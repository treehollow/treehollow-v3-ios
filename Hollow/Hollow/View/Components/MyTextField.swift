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
    var content: (() -> Content)? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title = title {
                Text(title.uppercased())
                    .font(.dynamic(size: 14, weight: .medium))
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
                .font(.dynamic(size: 16))
                Spacer()
                if let content = content {
                    content()
                }
            }
            .padding(10)
            .padding(.horizontal, 6)
            .background(Color.hollowCardBackground)
            .cornerRadius(10)
            
            if let footer = footer {
                Text(footer)
                    .font(.dynamic(size: 12))
                    .foregroundColor(.secondary)
                
            }
        }
    }
}

struct MyTextField_Previews: PreviewProvider {
    static var previews: some View {
        MyTextField<EmptyView>(text: .constant(""), placeHolder: "placeholder", title: "title")
    }
}
