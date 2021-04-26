//
//  View+showAlert.swift
//  HollowMac
//
//  Created by liang2kl on 2021/4/24.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func errorAlert(_ errorMessage: Binding<(title: String, message: String)?>) -> some View {
        return self
            .modifier(ErrorAlert(errorMessage: errorMessage))
    }
    
    func showInputAlert(title: String?, message: String?, placeholder: String?, onDismiss: @escaping (String?) -> Void) {
        let alert = NSAlert()
        if let title = title {
            alert.messageText = title
        }
        if let message = message {
            alert.informativeText = message
        }
        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        textField.placeholderString = placeholder
        alert.accessoryView = textField
        alert.addButton(withTitle: "INPUT_ALERT_BUTTON_CONFIRM")
        alert.addButton(withTitle: "INPUT_ALERT_BUTTON_CANCEL")
        let result = alert.runModal()
        switch result {
        case .alertFirstButtonReturn: onDismiss(textField.stringValue)
        default: onDismiss(nil)
        }
    }
}

struct AlertButtonConfiguration {
    var title: String
    var action: () -> Void = {}
    
    static func cancel(completion: @escaping () -> Void) -> AlertButtonConfiguration {
        AlertButtonConfiguration(title: "Cancel/", action: completion)
    }
    
    static func ok(completion: @escaping () -> Void) -> AlertButtonConfiguration {
        AlertButtonConfiguration(title: "OK/", action: completion)
    }
}

fileprivate func showAlert(title: String?, message: String?, buttons: [AlertButtonConfiguration], onCancel: (() -> Void)? = nil) {
    let alert = NSAlert()
    if let title = title {
        alert.messageText = title
    }
    if let message = message {
        alert.informativeText = message
    }

    for button in buttons.prefix(3) {
        alert.addButton(withTitle: button.title)
    }

    let result = alert.runModal()
    switch result {
    case .alertFirstButtonReturn: buttons[0].action()
    case .alertSecondButtonReturn: buttons[1].action()
    case .alertThirdButtonReturn: buttons[2].action()
    default: onCancel?()
    }
}


fileprivate struct ErrorAlert: ViewModifier {
    @Binding var errorMessage: (title: String, message: String)?
    
    func body(content: Content) -> some View {
        content
            .onChange(of: errorMessage?.1) { message in
                guard let errorMessage = errorMessage else { return }
                let title = errorMessage.title == "" ? errorMessage.message : errorMessage.title
                let message = errorMessage.title == "" ? "" : errorMessage.message
                showAlert(title: title, message: message, buttons: [.ok(completion: { self.errorMessage = nil })])
            }
    }
}
