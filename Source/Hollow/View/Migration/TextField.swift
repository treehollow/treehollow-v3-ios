//
//  TextField.swift
//  TextField
//
//  Created by liang2kl on 2021/8/21.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct TextField: View {
    @Binding var text: String
    var prompt: LocalizedStringKey?
    var onCommit: (() -> Void)?

    init(text: Binding<String>, prompt: LocalizedStringKey? = nil, onCommit: (() -> Void)? = nil) {
        self._text = text
        self.prompt = prompt
        self.onCommit = onCommit
    }
    
    init(text: Binding<String>, prompt: String? = nil, onCommit: (() -> Void)? = nil) {
        self._text = text
        self.prompt = prompt == nil ? nil : LocalizedStringKey(prompt!)
        self.onCommit = onCommit
    }
    
    var body: some View {
        if #available(iOS 15.0, *) {
            SwiftUI.TextField("", text: $text, prompt: prompt.isNil ? nil : Text(prompt!))
                .onSubmit { onCommit?() }
        } else {
            SwiftUI.TextField(prompt ?? "", text: $text, onCommit: { onCommit?() })
        }
    }
}

struct SecureField: View {
    @Binding var text: String
    var prompt: LocalizedStringKey?
    var onCommit: (() -> Void)?
    
    init(text: Binding<String>, prompt: LocalizedStringKey? = nil, onCommit: (() -> Void)? = nil) {
        self._text = text
        self.prompt = prompt
        self.onCommit = onCommit
    }
    
    init(text: Binding<String>, prompt: String? = nil, onCommit: (() -> Void)? = nil) {
        self._text = text
        self.prompt = prompt == nil ? nil : LocalizedStringKey(prompt!)
        self.onCommit = onCommit
    }

    var body: some View {
        if #available(iOS 15.0, *) {
            SwiftUI.SecureField("", text: $text, prompt: prompt.isNil ? nil : Text(prompt!))
                .onSubmit { onCommit?() }
        } else {
            SwiftUI.SecureField(prompt ?? "", text: $text, onCommit: { onCommit?() })
        }
    }
}
