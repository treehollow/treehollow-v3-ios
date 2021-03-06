//
//  IntegrationUtilities.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/20.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct IntegrationUtilities {
    static func topViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
    
    static func presentView<Content: View>(presentationStyle: UIModalPresentationStyle = .popover, transitionStyle: UIModalTransitionStyle = .coverVertical, @ViewBuilder content: () -> Content) {
        let vc = UIHostingController(rootView: content())
        vc.view.backgroundColor = nil
        vc.modalPresentationStyle = presentationStyle
        vc.modalTransitionStyle = transitionStyle
        guard let topVC = IntegrationUtilities.topViewController() else { return }
        topVC.present(vc, animated: true)
    }
}
