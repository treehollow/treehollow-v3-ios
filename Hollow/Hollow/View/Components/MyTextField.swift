//
//  MyTextField.swift
//  Hollow
//
//  Created by 梁业升 on 2021/1/30.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct MyTextField<Content>: View where Content: View {
    @Binding var text: String
    var placeHolder: String? = nil
    var title: String?
    var content: (() -> Content)? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title = title {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.hollowContentText)
            }
            HStack(spacing: 0) {
                TextField(placeHolder ?? "", text: $text)
                    .labelsHidden()
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(.system(size: 14))
                Spacer()
                if let content = content {
                    content()
                }
            }
            .padding(10)
            .background(Color.hollowCardBackground)
            .cornerRadius(8)
        }
    }
}

struct MyTextField_Previews: PreviewProvider {
    static var previews: some View {
        MyTextField<EmptyView>(text: .constant(""), placeHolder: "placeholder", title: "title")
    }
}
