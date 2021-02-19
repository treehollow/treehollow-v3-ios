//
//  View+customAlert.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/19.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func customAlert(presented: Binding<Bool>, title: String?, message: String?, actions: [CustomAlert.Action]) -> some View {
        self.modifier(CustomAlert(presented: presented, title: title, message: message, actions: actions))
    }
    
    func customAlert(alert: () -> CustomAlert) -> some View {
        self.modifier(alert())
    }
}

struct CustomAlert: ViewModifier {
    @Binding var presented: Bool
    var title: String?
    var message: String?
    var actions: [Action]
    
    func body(content: Content) -> some View {
        content
            .onChange(of: presented) { _ in
                if presented {
                    guard let topController = topViewController() else { return }
                    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    for action in actions {
                        let alertAction = UIAlertAction(title: action.text, style: action.style, handler: { _ in action.action() })
                        alertController.addAction(alertAction)
                    }
                    topController.present(alertController, animated: true, completion: { presented = false })
                }
            }
    }
    
    struct Action {
        var text: String
        var action: () -> Void
        var style: UIAlertAction.Style = .default
        static let cancel = Action(text: NSLocalizedString("Cancel", comment: ""), action: {}, style: .cancel)
        static let OK = Action(text: NSLocalizedString("OK", comment: ""), action: {})
    }
}

fileprivate func topViewController() -> UIViewController? {
    let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

    if var topController = keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
    return nil
}
