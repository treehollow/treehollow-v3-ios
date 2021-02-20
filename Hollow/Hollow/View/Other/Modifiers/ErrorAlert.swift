//
//  View+errorAlert.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/4.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct ErrorAlert: ViewModifier {
    @State private var presented: Bool = false
    @Binding var errorMessage: (title: String, message: String)?
    
    func body(content: Content) -> some View {
        return content
            .styledAlert(presented: $presented, title: errorMessage?.title ?? "", message: errorMessage?.message, buttons: [.init(text: "OK", style: .cancel, action: { errorMessage = nil })])
            .onChange(of: errorMessage?.message) { message in
                presented = message != nil
            }
    }
}
