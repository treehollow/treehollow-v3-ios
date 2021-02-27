//
//  View+presentPopover.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/27.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    /// Imperative method for synchronously presenting popover.
    func presentPopover<Content: View>(@ViewBuilder content: () -> Content) {
        let vc = UIHostingController(rootView: content())
        vc.modalPresentationStyle = .popover
        guard let topVC = IntegrationUtilities.topViewController() else { return }
        topVC.present(vc, animated: true)
    }
    
    func dismissSelf() {
        guard let topVC = IntegrationUtilities.topViewController() else { return }
        topVC.dismiss(animated: true)
    }
}