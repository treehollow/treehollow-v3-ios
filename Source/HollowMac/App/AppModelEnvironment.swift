//
//  AppModelEnvironment.swift
//  HollowMac
//
//  Created by liang2kl on 2021/4/24.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

protocol AppModelEnvironment: ObservableObject {
    var appModelState: AppModelState { get set }
}

extension AppModelEnvironment {
    /// Default implementation to handle token expire error.
    ///
    /// - parameter error: The request error
    /// - returns: `true` if the error is handled and should return, `false` otherwise.
    func handleTokenExpireError(_ error: DefaultRequestError) -> Bool {
        switch error {
        case .tokenExpiredError:
            Defaults[.accessToken] = nil
            appModelState.shouldShowMainView = false
            // TODO: Show Alert

            return true
        default: return false
        }
    }
    
    /// Error handler for default requests.
    func defaultErrorHandler(errorMessage: inout (title: String, message: String)?, error: DefaultRequestError) {
        if handleTokenExpireError(error) { return }
        if error.loadingCompleted() { return }
        errorMessage = (title: "", message: error.description)
    }
}

/// State definition reflecting the view model.
struct AppModelState {
    var errorMessage: (title: String, message: String)?

    var shouldShowMainView = Defaults[.accessToken] != nil
}
