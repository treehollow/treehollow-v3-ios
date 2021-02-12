//
//  KeyboardDismissBar.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/11.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct KeyboardDismissBarModifier: ViewModifier {
    @Binding var keyboardPresented: Bool
    @State private var dismiss: Bool = false

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
            if keyboardPresented {
                KeyboardDismissBar(keyboardPresented: $keyboardPresented)
            }
        }
    }
}

struct KeyboardDismissBar: View {
    @Binding var keyboardPresented: Bool
    var body: some View {
        Button(action: { keyboardPresented = false }) {
            Text("Done").fontWeight(.semibold)
        }
        .trailing()
        .padding()
        .blurBackground()
        .layoutPriority(1)
    }
}

struct KeyboardDismissBar_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardDismissBar(keyboardPresented: .constant(true))
    }
}
