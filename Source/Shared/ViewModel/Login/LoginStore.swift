//
//  LoginStore.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/28.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Combine
import Foundation
import SwiftUI
import Defaults
import HollowCore

/// View model for `LoginView`
class LoginStore: ObservableObject, HollowErrorHandler {

    @Published var showsRecaptcha = false
    @Published var reCAPTCHAToken: String = ""
    @Published var email: String = "" {
        didSet { if email != oldValue { restore() }}
    }
    @Published var emailCheckType: EmailCheckRequest.FinalResult?
    // Set to "" first because `WelcomeView` will load the initializer of `LoginView`
    // before we fetch the config.
    @Published var emailSuffix: String = Defaults[.hollowConfig]?.emailSuffixes.first ?? "" {
        didSet { if emailSuffix != oldValue { restore() }}
    }
    @Published var emailVerificationCode: String = ""
    @Published var originalPassword: String = ""
    @Published var confirmedPassword: String = ""
    @Published var loginPassword: String = ""
        
    @Published var errorMessage: (title: String, message: String)?
    
    @Published var isLoading = false
    
    var fullEmail: String { email + "@" + emailSuffix }
    
    private var cancellables = Set<AnyCancellable>()
    
    func checkEmail() {
        guard let config = Defaults[.hollowConfig] else { return }
        withAnimation {
            isLoading = true
        }

        var reCAPTCHAInfo: (String, EmailCheckRequest.Configuration.ReCAPTCHAVersion)? = nil
        if reCAPTCHAToken != "" {
            reCAPTCHAInfo = (reCAPTCHAToken, .v2)
        }
        
        let request = EmailCheckRequest(
            configuration: .init(
                apiRoot: config.apiRootUrls.first!, email: fullEmail,
                reCAPTCHAInfo: reCAPTCHAInfo)
        )
        
        request.publisher
            .sinkOnMainThread(receiveError: { error in
                withAnimation { self.isLoading = false }
                self.defaultErrorHandler(errorMessage: &self.errorMessage, error: error)
            }, receiveValue: { resultData in
                withAnimation {
                    self.isLoading = false
                    self.emailCheckType = resultData
                    if self.emailCheckType == .reCAPTCHANeeded {
                        self.showsRecaptcha = true
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    func register() {
        guard let config = Defaults[.hollowConfig] else { return }
        
        // It is a UI error that we allow the user to continue
        // when the two passwords don't match.
        guard originalPassword == confirmedPassword else { fatalError() }
        
        withAnimation {
            isLoading = true
        }

        let request = AccountCreationRequest(
            configuration: .init(
                email: fullEmail,
                password: originalPassword,
                validCode: emailVerificationCode,
                deviceToken: Defaults[.deviceToken],
                apiRoot: config.apiRootUrls.first!)
        )
        
        request.publisher
            .sinkOnMainThread(receiveError: { error in
                withAnimation { self.isLoading = false }
                self.defaultErrorHandler(errorMessage: &self.errorMessage, error: error)
            }, receiveValue: { result in
                withAnimation { self.isLoading = false }
                // We've got the token, it's time to enter the main interface.
                Defaults[.accessToken] = result.token
                AppModel.shared.isInMainView = true
            })
            .store(in: &cancellables)
    }
    
    func login() {
        guard let config = Defaults[.hollowConfig] else { return }

        withAnimation {
            isLoading = true
        }

        let request = LoginRequest(
            configuration: .init(
                email: fullEmail,
                password: loginPassword,
                deviceToken: Defaults[.deviceToken],
                apiRoot: config.apiRootUrls.first!)
        )
        
        request.publisher
            .sinkOnMainThread(receiveError: { error in
                withAnimation { self.isLoading = false }
                self.defaultErrorHandler(errorMessage: &self.errorMessage, error: error)
            }, receiveValue: { result in
                withAnimation { self.isLoading = false }
                // We've got the token, it's time to enter the main interface.
                Defaults[.accessToken] = result.token
                AppModel.shared.isInMainView = true
            })
            .store(in: &cancellables)
    }
    
    /// Restore the view model.
    func restore() {
        withAnimation {
            self.reCAPTCHAToken = ""
            self.emailCheckType = nil
            self.emailVerificationCode = ""
            self.loginPassword = ""
            self.originalPassword = ""
            self.confirmedPassword = ""
        }
    }
}

extension String {
    static let retriveDeviceTokenFailedMessageLocalized = NSLocalizedString("Fail to retrieve device token for remote notifications. Please try again.", comment: "")
}
