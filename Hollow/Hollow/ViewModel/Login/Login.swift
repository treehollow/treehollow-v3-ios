//
//  Login.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/28.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Combine
import Foundation
import Defaults

/// View model for `LoginView`
class Login: ObservableObject {
    @Published var reCAPTCHAPresented = false
    @Published var reCAPTCHAToken: String = ""
    @Published var email: String = ""
    @Published var emailCheckType: EmailCheckRequestResultData.ResultType?
    // FIXME: There should be something in the model to validate the hollow config!
    // Set to "" first because `WelcomeView` will load the initializer of `LoginView`
    // before we fetch the config.
    @Published var emailSuffix: String = Defaults[.hollowConfig]?.emailSuffixes.first ?? ""
    @Published var emailVerificationCode: String = ""
    @Published var originalPassword: String = ""
    
    @Published var errorMessage: (title: String, message: String)?
    
    func checkEmail() {
        guard let config = Defaults[.hollowConfig] else { return }
        guard email != "" else {
            errorMessage = (title: String.invalidInputLocalized.capitalized, message: NSLocalizedString("Email cannot be empty.", comment: ""))
            return
        }
        let request = EmailCheckRequest(configuration: .init(email: email + "@" + emailSuffix, hollowConfig: config))
        request.performRequest(completion: { resultData, error in
            if let error = error {
                debugPrint(error.description)
                switch error {
                case .decodeError:
                    self.errorMessage = (title: String.internalErrorLocalized.capitalized, message: error.description)
                case .other:
                    self.errorMessage = (title: String.errorLocalized.capitalized, message: error.description)
                }
                return
            }
            debugPrint(resultData as Any)
            self.emailCheckType = resultData?.result
            
            if self.emailCheckType == .reCAPTCHANeeded {
                self.reCAPTCHAPresented = true
            }
        })
    }
    
    func register() {
        
    }
    
    func login() {
        
    }
}
