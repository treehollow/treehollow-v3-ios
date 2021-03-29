//
//  View+presentStyledAlert.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/29.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func presentStyledAlert(title: String, message: String? = nil, buttons: [StyledAlertButton]) {
        let alert = StyledAlert(presented: .constant(true), selfDismiss: true, title: title, message: message, buttons: buttons)
        IntegrationUtilities.presentView(presentationStyle: .overFullScreen, transitionStyle: .crossDissolve, content: { alert })
    }
}
