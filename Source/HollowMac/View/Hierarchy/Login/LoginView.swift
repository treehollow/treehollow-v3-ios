//
//  LoginView.swift
//  HollowMac
//
//  Created by liang2kl on 2021/4/24.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

struct LoginView: View {
    @ObservedObject var store = LoginStore()
    @Environment(\.presentationMode) var presentationMode
    
    // Determine when we should check user's email.
    private var shouldCheckEmail: Bool { store.emailCheckType == nil || store.emailCheckType == .reCAPTCHANeeded }
    
    // Determine when the user should register with verification code and password.
    private var shouldRegister: Bool { store.emailCheckType == .newUser }
    
    // Determine when the user should enter the password to login.
    private var shouldLogin: Bool { store.emailCheckType == .oldUser }
    
    private var buttonText: String {
        if store.isLoading { return NSLocalizedString("LOGINVIEW_BUTTON_LOADING", comment: "") + "..." }
        if shouldCheckEmail { return NSLocalizedString("LOGINVIEW_BUTTON_CONTINUE", comment: "") }
        if shouldRegister { return NSLocalizedString("LOGINVIEW_BUTTON_REGISTER", comment: "") }
        if shouldLogin { return NSLocalizedString("LOGINVIEW_BUTTON_LOGIN", comment: "") }
        return ""
    }
    
    // Determine when to disable the interaction with the text fields
    private var disableInteraction: Bool { store.isLoading }
    
    // Determine when to disable the button
    private var disableButton: Bool {
        if store.isLoading { return true }
        if shouldCheckEmail { return store.email == "" }
        if shouldRegister { return
            store.emailVerificationCode == "" ||
            store.confirmedPassword != store.originalPassword ||
            // Invalid original password
            store.originalPassword.count < 8 ||
            store.originalPassword.contains(" ")
        }
        if shouldLogin { return store.loginPassword == "" }
        return true
    }
    

    var body: some View {
        VStack(spacing: 20) {
            if let title = Defaults[.hollowConfig]?.name {
                Text(title)
                    .font(.headline)
            }
            GroupBox(label: Text("Email"), content: {
                HStack {
                    TextField("", text: $store.email)
                    Menu(content: {
                        ForEach(Defaults[.hollowConfig]?.emailSuffixes ?? [], id: \.self) { suffix in
                            Button("\(suffix)") {
                                store.emailSuffix = suffix
                            }
                        }
                    }, label: {
                        Text("@\(store.emailSuffix)")
                    })
                    .frame(maxWidth: 200)
//                    .menuStyle(BorderlessButtonMenuStyle())
                }
                .sheet(isPresented: $store.showsRecaptcha) {
                    ReCAPTCHAPageView(
                        presented: $store.showsRecaptcha,
                        successHandler: { token in
                            withAnimation {
                                store.showsRecaptcha = false
                                store.reCAPTCHAToken = token
                                // Check again with the token
                                store.checkEmail()
                            }
                        }
                    )
                    .frame(minWidth: 400, minHeight: 600)
                }
            })
            
            if shouldRegister {
                Divider()
                RegisterTextFields().environmentObject(store)
            }
            
            if shouldLogin {
                LoginTextFields().environmentObject(store)
            }
            
            Spacer()
        }
        .textFieldStyle(PlainTextFieldStyle())
        .padding()
        .frame(minHeight: shouldRegister ? 400 : nil)
        .frame(minHeight: shouldLogin ? 300 : nil)
        .frame(minWidth: 200)
        .disabled(disableInteraction)
        .toolbar {
            Button("Close", action: { presentationMode.wrappedValue.dismiss() })
                .keyboardShortcut(.cancelAction)

            Button(buttonText) {
                if shouldCheckEmail { store.checkEmail() }
                if shouldRegister { store.register() }
                if shouldLogin { store.login() }
            }
            .keyboardShortcut(.defaultAction)
            .disabled(disableButton)
        }
        .errorAlert($store.errorMessage)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
