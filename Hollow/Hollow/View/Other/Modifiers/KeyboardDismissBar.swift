//
//  KeyboardDismissBar.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/11.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct KeyboardDismissBarModifier: ViewModifier {
    @Binding var editing: Bool
    @State private var keyboardOnScreen = false

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
            if keyboardOnScreen && editing {
                KeyboardDismissBar(editing: $editing)
                    .layoutPriority(1)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation { keyboardOnScreen = true }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation { keyboardOnScreen = false }
        }
    }
}

struct KeyboardDismissBar: View {
    @Binding var editing: Bool
    var body: some View {
        Button(action: { withAnimation { editing = false }}) {
            Text("Done").fontWeight(.semibold)
        }
        .trailing()
        .padding()
        .background(Color.uiColor(.systemBackground))
        .layoutPriority(1)
    }
}

struct KeyboardDismissBar_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardDismissBar(editing: .constant(true))
    }
}
