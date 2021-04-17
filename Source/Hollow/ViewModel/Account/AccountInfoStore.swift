//
//  AccountInfoStore.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/8.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Combine
import Defaults

class AccountInfoStore: ObservableObject, AppModelEnvironment {
    @Published var appModelState = AppModelState()
    @Published var errorMessage: (title: String, message: String)?
    @Published var isLoading = false
    
    var cancellables = Set<AnyCancellable>()
    
    func logout() {
        guard let config = Defaults[.hollowConfig],
              let token = Defaults[.accessToken] else { return }

        withAnimation { isLoading = true }
        LogoutRequest(configuration: .init(token: token, apiRoot: config.apiRootUrls)).publisher
            .sinkOnMainThread(receiveError: { error in
                withAnimation { self.isLoading = false }
                self.defaultErrorHandler(errorMessage: &self.errorMessage, error: error)
            }, receiveValue: { _ in
                withAnimation {
                    self.isLoading = false
                    self.appModelState.shouldShowMainView = false
                    Defaults[.accessToken] = nil
                }
            })
            .store(in: &cancellables)
    }
    
    func changePassword(for email: String, original originalPassword: String, new newPassword: String) {
        guard let config = Defaults[.hollowConfig] else { return }

        withAnimation { isLoading = true }
        let configuration = ChangePasswordRequestConfiguration(email: email, oldPassword: originalPassword, newPassword: newPassword, apiRoot: config.apiRootUrls)
        let request = ChangePasswordRequest(configuration: configuration)
        
        withAnimation { isLoading = true }
        request.publisher
            .sinkOnMainThread(receiveError: { error in
                withAnimation { self.isLoading = false }
                self.defaultErrorHandler(errorMessage: &self.errorMessage, error: error)
            }, receiveValue: { _ in
                withAnimation { self.isLoading = false }
                self.errorMessage = (title: NSLocalizedString("CHANGE_PASSWORD_SUCCESS_ALERT_TITLE", comment: ""), message: "")
                self.appModelState.shouldShowMainView = false
                Defaults[.accessToken] = nil
            })
            .store(in: &cancellables)
    }
}
