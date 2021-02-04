//
//  View+errorAlert.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/4.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct ErrorAlert: ViewModifier {
    @Binding var errorMessage: (title: String, message: String)?
    
    func body(content: Content) -> some View {
        return content
            .alert(isPresented: .constant(errorMessage != nil)) {
                // We should restore the error message after presenting the alert
                Alert(title: Text(errorMessage!.title), message: Text(errorMessage!.message), dismissButton: .default(Text(LocalizedStringKey("OK")), action: { errorMessage = nil }))
            }
    }
}
