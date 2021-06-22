//
//  HollowErrorHandler.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/15.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults
import HollowCore

/// Protocol for a view model which protentially modify the shared `AppModel` instance.
protocol HollowErrorHandler: ObservableObject {}

extension HollowErrorHandler {
    /// Default implementation to handle token expire error.
    ///
    /// - parameter error: The request error
    /// - returns: `true` if the error is handled and should return, `false` otherwise.
    func handleTokenExpireError(_ error: DefaultRequestError) -> Bool {
        switch error {
        case .tokenExpiredError:
            tokenExpiredHandler()
            return true
        default: return false
        }
    }
    
    /// Error handler for default requests.
    func defaultErrorHandler(errorMessage: inout (title: String, message: String)?, error: DefaultRequestError) {
        if handleTokenExpireError(error) { return }
        errorMessage = (title: "", message: error.localizedDescription)
    }
    
    func tokenExpiredHandler() {
        restore()
        withAnimation {
            AppModel.shared.isInMainView = false
        }
        // FIXME: Show Alert in macOS
        #if !os(macOS) || targetEnvironment(macCatalyst)
        ToastManager.shared.show(configuration: .error(title: nil, body: NSLocalizedString("WELCOMVIEW_TOKEN_EXPIRED_LABEL", comment: "")))
        #endif
    }
    
    private func restore() {
        Defaults[.accessToken] = nil
        restoreDefaults()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    private func restoreDefaults() {
        Defaults.Keys.customConfigURL.reset()
        Defaults.Keys.accessToken.reset()
        Defaults.Keys.hiddenAnnouncement.reset()
        Defaults.Keys.deviceListCache.reset()
    }
}
