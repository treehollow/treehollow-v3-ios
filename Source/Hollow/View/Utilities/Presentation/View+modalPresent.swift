//
//  View+modalPresent.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func modalPresent<Content: View>(presented: Binding<Bool>, presentationStyle: UIModalPresentationStyle = .overFullScreen, transitionStyle: UIModalTransitionStyle = .coverVertical, @ViewBuilder content: () -> Content) -> some View {
        return self
            .modifier(ModalPresent(presented: presented, presentedContent: content(), presentationStyle: presentationStyle, transitionStyle: transitionStyle))
    }
}

fileprivate struct ModalPresent<PresentedContent: View>: ViewModifier {
    @Binding var presented: Bool
    let presentedContent: PresentedContent
    var presentationStyle: UIModalPresentationStyle
    var transitionStyle: UIModalTransitionStyle
    func body(content: Content) -> some View {
        content
            .onChange(of: presented) { _ in
                guard let topVC = IntegrationUtilities.topViewController() else { return }
                if presented {
                    let newVC = UIHostingController(rootView: presentedContent)
                    newVC.view.backgroundColor = nil
                    newVC.modalPresentationStyle = presentationStyle
                    newVC.modalTransitionStyle = transitionStyle
                    topVC.present(newVC, animated: true)
                } else {
                    // Top view controller is our presented controller
                    topVC.dismiss(animated: true)
                }
            }
    }
}
