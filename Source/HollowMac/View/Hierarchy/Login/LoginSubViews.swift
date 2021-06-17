//
//  LoginSubViews.swift
//  HollowMac
//
//  Created by liang2kl on 2021/4/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension LoginView {
    struct RegisterTextFields: View {
        @EnvironmentObject var store: LoginStore
        // The password is valid only if its length is no less than 8 and it contains no blank spaces.
        private var passwordValid: Bool {
            store.originalPassword.count >= 8 &&
                !store.originalPassword.contains(" ")
        }
        
        private var confirmedPasswordValid: Bool {
            store.confirmedPassword == store.originalPassword
        }
        
        private let passwordRequirements: String =
            NSLocalizedString("LOGINVIEW_PASSWORD_TEXTFIELD_REQUIREMENT_FOOTER", comment: "")

        var body: some View {
            GroupBox(label: Text("Verification Code"), content: {
                TextField("", text: $store.emailVerificationCode, prompt: Text(verbatim: "123456"))
            })
            
            GroupBox(label: Text("Password"), content: {
                HStack {
                    SecureField("", text: $store.originalPassword, prompt: Text(passwordRequirements))

                    Group {
                        if store.originalPassword != "" && !passwordValid {
                            Image(systemName: "xmark")
                                .foregroundColor(.red)
                        } else if store.originalPassword != "" {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }

                }

            })
            
            GroupBox(label: Text("Confirmed Password"), content: {
                HStack {
                    SecureField("", text: $store.confirmedPassword)
                    
                    if passwordValid {
                        if store.confirmedPassword != "" && !confirmedPasswordValid {
                            Image(systemName: "xmark")
                                .foregroundColor(.red)
                        } else if store.confirmedPassword != "" {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }

                }

            })
        }
    }
    
    struct LoginTextFields: View {
        @EnvironmentObject var store: LoginStore
        
        var body: some View {
            GroupBox(label: Text("Password"), content: {
                SecureField("", text: $store.loginPassword)
            })
        }
    }
}
