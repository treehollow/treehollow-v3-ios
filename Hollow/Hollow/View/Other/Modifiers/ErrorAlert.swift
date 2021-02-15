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
                ErrorAlert.alert(errorMessage: $errorMessage)!
            }
    }
    
    static func alert(errorMessage: Binding<(title: String, message: String)?>) -> Alert? {
        guard errorMessage.wrappedValue != nil else { return nil }
        return Alert(
            title: Text(errorMessage.wrappedValue!.title),
            message: Text(errorMessage.wrappedValue!.message),
            dismissButton: .default(
                Text(LocalizedStringKey("OK")),
                // We should restore the error message after presenting the alert
                action: { errorMessage.wrappedValue = nil }
            )
        )
    }
}
