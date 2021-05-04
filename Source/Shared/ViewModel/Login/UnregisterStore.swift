//
//  UnregisterStore.swift
//  Hollow
//
//  Created by liang2kl on 2021/5/2.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Combine
import Defaults
import SwiftUI

class UnregisterStore: ObservableObject, AppModelEnvironment {
    var presented: Binding<Bool>
    @Published var appModelState = AppModelState()
    @Published var email = "" {
        didSet { if email != oldValue { restore() } }
    }
    @Published var nonce = ""
    @Published var validCode = ""
    @Published var recaptchaToken: String?
    @Published var emailCheckType: UnregisterCheckEmailRequestResultData?

    @Published var errorMessage: (title: String, message: String)?
    @Published var isLoading = false
    @Published var showsRecaptcha = false
    
    var cancellables = Set<AnyCancellable>()
    
    init(email: String, presented: Binding<Bool> = .constant(true)) {
        self.email = email
        self.presented = presented
    }
    
    init(presented: Binding<Bool> = .constant(true)) {
        self.presented = presented
    }
    
    func checkEmail() {
        guard email != "" else { return }
        guard let apiRoot = Defaults[.hollowConfig]?.apiRootUrls else { return }
        let configuration = UnregisterCheckEmailRequestConfiguration(email: email, recaptchaToken: recaptchaToken, apiRoot: apiRoot)
        let request = UnregisterCheckEmailRequest(configuration: configuration)
        
        withAnimation { isLoading = true }
        
        request.publisher
            .sinkOnMainThread(receiveError: {
                withAnimation { self.isLoading = false }
                self.defaultErrorHandler(errorMessage: &self.errorMessage, error: $0)
            }, receiveValue: { data in
                withAnimation { self.isLoading = false }
                self.emailCheckType = data
                if data == .needReCAPTCHA {
                    self.showsRecaptcha = true
                    // Present here as there are bugs with presenting with our view.
                    IntegrationUtilities.presentView(presentationStyle: .overFullScreen, content: {
                        ReCAPTCHAPageView(
                            presented: .constant(true),
                            selfDismiss: true,
                            successHandler: { token in
                                withAnimation {
                                    self.showsRecaptcha = false
                                    self.recaptchaToken = token
                                    // Check again with the token
                                    self.checkEmail()
                                }
                            }
                        )
                        .background(Color.uiColor(.systemBackground).ignoresSafeArea())
                    })
                }
                
            })
            .store(in: &cancellables)
    }
    
    func unregister() {
        guard let config = Defaults[.hollowConfig] else { return }
        let configuration = UnregisterRequestConfiguration(email: email, nonce: nonce, validCode: validCode, apiRoot: config.apiRootUrls)
        let request = UnregisterRequest(configuration: configuration)
        
        withAnimation { isLoading = true }
        
        request.publisher
            .sinkOnMainThread(receiveError: {
                withAnimation { self.isLoading = false }
                self.defaultErrorHandler(errorMessage: &self.errorMessage, error: $0)
            }, receiveValue: { _ in
                _ = self.handleTokenExpireError(.tokenExpiredError)
                self.presented.wrappedValue = false
            })
            .store(in: &cancellables)
    }
    
    func restore() {
        withAnimation {
            self.recaptchaToken = ""
            self.emailCheckType = nil
            self.nonce = ""
            self.validCode = ""
        }
    }

}
