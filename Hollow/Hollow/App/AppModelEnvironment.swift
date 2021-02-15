//
//  AppModelEnvironment.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/15.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

/// Protocol for a view model to internally define states of the app.
///
/// Conform this protocol to the view model whose corresponding view is (and must be)
/// modified by `.modifier(AppModelBehaviour(state: viewModel.state))`.
/// Change the variables inside `state` will automatically update the app model.
protocol AppModelEnvironment: ObservableObject {
    var state: AppModelState { get set }
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
            state.shouldShowMainView = false
            return true
        default: return false
        }
    }
}

/// State definition reflecting the view model.
struct AppModelState {
    var errorMessage: (title: String, message: String)?
    // It might be buggy
    var shouldShowMainView = Defaults[.accessToken] != nil
}
