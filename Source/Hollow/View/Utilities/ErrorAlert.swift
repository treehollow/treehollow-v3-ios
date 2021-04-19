//
//  View+errorAlert.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/4.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct ErrorAlert: ViewModifier {
    var type: AlertType = .error
    var anchor: Toast.Anchor?
    @State private var presented: Bool = false
    @Binding var errorMessage: (title: String, message: String)?
    
    func body(content: Content) -> some View {
        return content
            .onChange(of: errorMessage?.message) { message in
                if let message = message {
                    content.showToast(configuration: .init(message: (title: errorMessage?.title, body: message), style: type.style, type: type.toastType, anchor: anchor ?? .bottom))
                    errorMessage = nil
                }
            }
    }
    
    enum AlertType {
        case success, error
        var style: Toast.Style {
            switch self {
            case .success: return .success
            case .error: return .error
            }
        }
        var toastType: Toast.ToastType {
            switch self {
            case .success: return .success
            case .error: return .error
            }
        }

    }
}
