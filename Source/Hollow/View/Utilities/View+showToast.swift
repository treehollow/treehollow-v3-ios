//
//  View+showToast.swift
//  Hollow
//
//  Created by liang2kl on 2021/4/17.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func showToast(configuration: Toast.Configuration) {
        ToastManager.shared.show(configuration: configuration)
    }
    
    func showSuccessToast(title: String?, message: String?, anchor: Toast.Anchor? = nil, onTap: (() -> Void)? = nil) {
        ToastManager.shared.show(configuration: .success(title: title, body: message, anchor: anchor ?? .bottom, onTap: onTap))
    }
    
    func showErrorToast(title: String?, message: String?, anchor: Toast.Anchor? = nil, onTap: (() -> Void)? = nil) {
        ToastManager.shared.show(configuration: .error(title: title, body: message, anchor: anchor ?? .bottom, onTap: onTap))
    }
}
