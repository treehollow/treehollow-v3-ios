//
//  UnregisterView.swift
//  Hollow
//
//  Created by liang2kl on 2021/5/2.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct UnregisterView: View {
    @ObservedObject var store = UnregisterStore()
    
    private var shouldCheckEmail: Bool {
        store.emailCheckType == nil || store.emailCheckType == .needReCAPTCHA
    }
    
    private var buttonText: String {
        if store.isLoading { return NSLocalizedString("LOGINVIEW_BUTTON_LOADING", comment: "") + "..." }
        if shouldCheckEmail { return NSLocalizedString("LOGINVIEW_BUTTON_CONTINUE", comment: "") }
        return NSLocalizedString("UNREGISTERVIEW_BUTTON_UNREGISTER", comment: "")
    }
    
    private var disableButton: Bool {
        if store.isLoading { return true }
        if shouldCheckEmail { return store.email == "" }
        return store.email == "" ||
            store.nonce == "" ||
            store.validCode == ""
    }
    
    var body: some View {
        VStack(spacing: 0) {
            #if targetEnvironment(macCatalyst)
            Text("UNREGISTERVIEW_NOT_SUPPORT_MAC_NOTICE")
                .horizontalCenter()
                .verticalCenter()
            #else
            ScrollView(showsIndicators: false) {
                VStack(spacing: ViewConstants.listVStackSpacing) {
                    MyTextField<EmptyView>(
                        text: $store.email,
                        placeHolder: NSLocalizedString("LOGINVIEW_EMAIL_TEXTFIELD_PLACEHOLDER", comment: ""),
                        title: NSLocalizedString("LOGINVIEW_EMAIL_TEXTFIELD_TITLE", comment: "")
                    )
                    .padding(.top)
                    
                    if !shouldCheckEmail {
                        MyTextField<EmptyView>(
                            text: $store.nonce,
                            placeHolder: NSLocalizedString("UNREGISTERVIEW_NONCE_TEXTFIELD_PLACEHOLDER", comment: ""),
                            title: NSLocalizedString("UNREGISTERVIEW_NONCE_TEXTFIELD_TITLE", comment: ""),
                            footer: NSLocalizedString("UNREGISTERVIEW_NONCE_FOOTER", comment: "")
                        )
                        
                        MyTextField<EmptyView>(
                            text: $store.validCode,
                            title: NSLocalizedString("LOGINVIEW_EMAIL_VERIF_TEXTFIELD_TITLE", comment: ""),
                            footer: NSLocalizedString("LOGINVIEW_EMAIL_VERIF_TEXTFIELD_FOOTER", comment: "")
                        )
                        .keyboardType(.numberPad)

                    }
                }
            }
            
            ExpandedButton(
                action: {
                    hideKeyboard()
                    if shouldCheckEmail { store.checkEmail() }
                    else {
                        presentStyledAlert(
                            title: NSLocalizedString("LOGINVIEW_RESTORE_PASSWORD_ALERT_UNREGISTER_BUTTON", comment: ""),
                            message: NSLocalizedString("UNREGISTERVIEW_ALERT_MSG", comment: ""),
                            buttons: [
                                .init(text: NSLocalizedString("UNREGISTERVIEW_ALERT_CONFIRM", comment: ""), action: {
                                    store.unregister()
                                }),
                                .cancel
                            ]
                        )
                    }
                },
                transitionAnimation: .default,
                text: buttonText
            )
            .disabled(disableButton)
            #endif
        }
        .padding(.horizontal)
        .padding(.horizontal)
        .padding(.bottom)
        .background(Color.background.edgesIgnoringSafeArea(.all))

        .fullScreenCover(isPresented: $store.showsRecaptcha) {
            ReCAPTCHAPageView(
                presented: $store.showsRecaptcha,
                successHandler: { token in
                    withAnimation {
                        store.showsRecaptcha = false
                        store.recaptchaToken = token
                        // Check again with the token
                        store.checkEmail()
                    }
                }
            )
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("LOGINVIEW_RESTORE_PASSWORD_ALERT_UNREGISTER_BUTTON")
        .modifier(ErrorAlert(errorMessage: $store.errorMessage))
        .modifier(AppModelBehaviour(state: store.appModelState))
    }
}
