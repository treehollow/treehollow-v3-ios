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

class AccountInfoStore: ObservableObject, HollowErrorHandler {
    @Published var errorMessage: (title: String, message: String)?
    @Published var isLoading = false
    
    var cancellables = Set<AnyCancellable>()
    
    func logout(force: Bool = false) {
        if force {
            withAnimation { self.tokenExpiredHandler() }
            return
        }

        guard let config = Defaults[.hollowConfig],
              let token = Defaults[.accessToken] else { return }
        
        withAnimation { isLoading = true }
        LogoutRequest(configuration: .init(apiRoot: config.apiRootUrls.first!, token: token)).publisher
            .sinkOnMainThread(receiveError: { error in
                withAnimation { self.isLoading = false }
                self.defaultErrorHandler(errorMessage: &self.errorMessage, error: error)
            }, receiveValue: { _ in
                withAnimation {
                    self.isLoading = false
                    self.tokenExpiredHandler()
                }
            })
            .store(in: &cancellables)
    }
    
    func changePassword(for email: String, original originalPassword: String, new newPassword: String) {
        guard let config = Defaults[.hollowConfig] else { return }

        withAnimation { isLoading = true }
        let configuration = ChangePasswordRequest.Configuration(apiRoot: config.apiRootUrls.first!, email: email, oldPassword: originalPassword, newPassword: newPassword)
        let request = ChangePasswordRequest(configuration: configuration)
        
        withAnimation { isLoading = true }
        request.publisher
            .sinkOnMainThread(receiveError: { error in
                withAnimation { self.isLoading = false }
                self.defaultErrorHandler(errorMessage: &self.errorMessage, error: error)
            }, receiveValue: { _ in
                withAnimation { self.isLoading = false }

                ToastManager.shared.show(configuration: .success(title: nil, body: NSLocalizedString("CHANGE_PASSWORD_SUCCESS_ALERT_TITLE", comment: "")))

                
                self.tokenExpiredHandler()
            })
            .store(in: &cancellables)
    }
}
