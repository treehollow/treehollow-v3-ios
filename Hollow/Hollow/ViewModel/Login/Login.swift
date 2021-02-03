//
//  Login.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/28.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Combine
import Foundation
import SwiftUI
import Defaults

/// View model for `LoginView`
class Login: ObservableObject {
    @Published var fullScreenCoverIndex = -1
    @Published var reCAPTCHAToken: String = ""
    @Published var email: String = "" { didSet { restore() }}
    @Published var emailCheckType: EmailCheckRequestResultData.ResultType?
    // FIXME: There should be something in the model to validate the hollow config!
    // Set to "" first because `WelcomeView` will load the initializer of `LoginView`
    // before we fetch the config.
    @Published var emailSuffix: String = Defaults[.hollowConfig]?.emailSuffixes.first ?? "" { didSet { restore() }}
    @Published var emailVerificationCode: String = ""
    @Published var originalPassword: String = ""
    @Published var confirmedPassword: String = ""
    @Published var loginPassword: String = ""
        
    @Published var errorMessage: (title: String, message: String)?
    
    @Published var isLoading = false
    
    private var fullEmail: String { email + "@" + emailSuffix }
    
    func checkEmail() {
        guard let config = Defaults[.hollowConfig] else { return }
        guard email != "" else {
            errorMessage = (title: String.invalidInputLocalized.capitalized, message: NSLocalizedString("Email cannot be empty.", comment: ""))
            return
        }
        isLoading = true
        print("email: \(email + "@" + emailSuffix)")
        var reCAPTCHAInfo: (String, EmailCheckRequestConfiguration.ReCAPTCHAVersion)? = nil
        if reCAPTCHAToken != "" {
            reCAPTCHAInfo = (reCAPTCHAToken, .v2)
        }
        let request = EmailCheckRequest(configuration: .init(email: fullEmail, reCAPTCHAInfo: reCAPTCHAInfo, apiRoot: config.apiRoot))
        request.performRequest(completion: { resultData, error in
            self.isLoading = false
            if let error = error {
                self.handleError(error: error)
                return
            }
            debugPrint(resultData as Any)
            
            withAnimation {
                self.emailCheckType = resultData?.result
                
                if self.emailCheckType == .reCAPTCHANeeded {
                    self.fullScreenCoverIndex = 0
                }
            }
        })
    }
    
    func register() {
        guard let config = Defaults[.hollowConfig] else { return }
        isLoading = true

        let request = AccountCreationRequest(configuration: .init(email: fullEmail, password: originalPassword, validCode: emailVerificationCode, deviceToken: "placeholder", apiRoot: config.apiRoot))
        request.performRequest(completion: { result, error in
            self.isLoading = false

            if let error = error {
                self.handleError(error: error)
                return
            }
            if let result = result {
                Defaults[.accessToken] = result.token
                self.fullScreenCoverIndex = 1
            }
        })
    }
    
    func login() {
        guard let config = Defaults[.hollowConfig] else { return }
        isLoading = true

        let request = LoginRequest(configuration: .init(email: fullEmail, password: loginPassword, deviceToken: "placeholder", apiRoot: config.apiRoot))
        request.performRequest(completion: { result, error in
            self.isLoading = false

            if let error = error {
                self.handleError(error: error)
                return
            }
            
            if let result = result {
                Defaults[.accessToken] = result.token
                self.fullScreenCoverIndex = 1
            }
        })
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
    
    private func handleError(error: DefaultRequestError) {
        debugPrint(error.description)

        switch error {
        case .decodeFailed:
            self.errorMessage = (title: String.internalErrorLocalized.capitalized, message: error.description)
        default:
            self.errorMessage = (title: String.errorLocalized.capitalized, message: error.description)
        }
        
    }
}
