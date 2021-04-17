//
//  View+presentView.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/27.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    /// Imperative method for synchronously presenting popover.
    func presentView<Content: View>(style: UIModalPresentationStyle = .formSheet, transitionStyle: UIModalTransitionStyle = .coverVertical, @ViewBuilder content: () -> Content) {
        IntegrationUtilities.presentView(presentationStyle: style, transitionStyle: transitionStyle, content: content)
    }
    
    func dismissSelf() {
        guard let topVC = IntegrationUtilities.topViewController() else { return }
        topVC.dismiss(animated: true)
    }
}
