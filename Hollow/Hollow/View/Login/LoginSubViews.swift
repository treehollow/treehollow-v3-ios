//
//  LoginSubViews.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/4.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

// Sub views of `LoginView`, we put them here to
// improve code hightlight and completion performance.
extension LoginView {
    struct ReCAPTCHAPageView: View {
        @Binding var presentedIndex: Int
        let successHandler: (String) -> Void
        @State private var pageLoadingFinish = false
        
        @ScaledMetric(wrappedValue: 20, relativeTo: .body) var body20: CGFloat

        var body: some View {
            VStack {
                Button(action: {
                    withAnimation {
                        presentedIndex = -1
                    }
                }) {
                    Image(systemName: "xmark")
                        .imageButton(sizeFor20: body20)
                        .padding(.bottom)
                }
                .leading()
                ReCAPTCHAWebView(onFinishLoading: {
                    withAnimation {
                        pageLoadingFinish = true
                    }
                }, successHandler: successHandler)
                .onAppear {
                    pageLoadingFinish = false
                }
            }
            .padding()
            .overlay(Group {
                if !pageLoadingFinish {
                    Spinner(color: .buttonGradient1, desiredWidth: 30)
                }
            })
            
        }
    }
    
    struct RegisterTextFields: View {
        @ObservedObject var viewModel: Login
        
        @ScaledMetric(wrappedValue: 14, relativeTo: .body) var body14: CGFloat
        
        // The password is valid only if its length is no less than 8 and it contains no blank spaces.
        private var passwordValid: Bool {
            viewModel.originalPassword.count >= 8 &&
                !viewModel.originalPassword.contains(" ")
        }
        
        private var confirmedPasswordValid: Bool {
            viewModel.confirmedPassword == viewModel.originalPassword
        }
        
        private let passwordRequirements: String =
            NSLocalizedString("The password should contains at least 8 characters without blank spaces.", comment: "")
        
        var body: some View {
            // Verification code text field
            MyTextField<EmptyView>(text: $viewModel.emailVerificationCode, title: String.verificationCodeLocalized.capitalized, footer: NSLocalizedString("Please check your inbox.", comment: ""))
                .keyboardType(.numberPad)
            
            // Password text field
            MyTextField(text: $viewModel.originalPassword, title: String.passwordLocalized.capitalized, footer: passwordRequirements, isSecureContent: true) {
                Group {
                    if viewModel.originalPassword != "" && !passwordValid {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                    } else if viewModel.originalPassword != "" {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                }
                .font(.system(size: body14))
            }
            
            // Confirmed password text field
            MyTextField(text: $viewModel.confirmedPassword,
                        title: String.confirmedPassWordLocalized.capitalized,
                        isSecureContent: true) {
                Group {
                    // Original password should be valid first.
                    if passwordValid {
                        if viewModel.confirmedPassword != "" && !confirmedPasswordValid {
                            Image(systemName: "xmark")
                                .foregroundColor(.red)
                        } else if viewModel.confirmedPassword != "" {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }
                }
                .font(.system(size: body14))
            }
        }
    }
    
    struct FullScreenCoverContent: View {
        @ObservedObject var viewModel: Login
        
        var body: some View {
            Group {
                // Present reCAPTCHA verification interface when needed
                if viewModel.fullScreenCoverIndex == 0 {
                    ReCAPTCHAPageView(
                        presentedIndex: $viewModel.fullScreenCoverIndex,
                        successHandler: { token in
                            withAnimation {
                                viewModel.fullScreenCoverIndex = -1
                                viewModel.reCAPTCHAToken = token
                                // Check again with the token
                                viewModel.checkEmail()
                            }
                        }
                    )
                }
                
                // Present main view after successfully logging in
                if viewModel.fullScreenCoverIndex == 1 {
                    MainView()
                }
            }
        }
    }
    
    struct EmailTextField: View {
        @ObservedObject var viewModel: Login
        private let configuration = Defaults[.hollowConfig]!
        
        @ScaledMetric(wrappedValue: 14, relativeTo: .body) var body14: CGFloat

        var body: some View {
            MyTextField(text: $viewModel.email,
                        placeHolder: NSLocalizedString("Enter your email", comment: ""),
                        title: String.emailAddressLocalized.firstLetterUppercased) {
                // Accessory view for selecting email suffix
                Menu(content: {
                    ForEach(configuration.emailSuffixes.indices, id: \.self) { index in
                        Button(configuration.emailSuffixes[index], action: {
                            viewModel.emailSuffix = configuration.emailSuffixes[index]
                        })
                    }
                }, label: {
                    HStack {
                        Text("@" + viewModel.emailSuffix)
                        Image(systemName: "chevron.down")
                            .layoutPriority(1)
                    }
                    .lineLimit(1)
                    .font(.system(size: body14))
                    .foregroundColor(.hollowContentText)
                })
            }
            .keyboardType(.emailAddress)
        }
    }
    
    struct LoginTextField: View {
        @ObservedObject var viewModel: Login
        @State private var alertPresented = false
        @State private var contactEmailURL: URL!
        @Environment(\.openURL) var openURL
        
        @ScaledMetric(wrappedValue: 12, relativeTo: .footnote) var footnote12: CGFloat

        var body: some View {
            VStack(alignment: .leading) {
                MyTextField<EmptyView>(text: $viewModel.loginPassword,
                                       placeHolder: NSLocalizedString("Enter your password", comment: ""),
                                       title: String.passwordLocalized.capitalized,
                                       isSecureContent: true)
                Button(action: {
                    if let mailString = Defaults[.hollowConfig]?.contactEmail,
                       let url = URL(string: "mailto:\(mailString)") {
                        contactEmailURL = url
                        alertPresented = true
                    } else {
                        viewModel.errorMessage = (
                            title: String.errorLocalized.capitalized,
                            message: NSLocalizedString("No contact email found in the treehollow configuration.", comment: "")
                        )
                    }
                }) {
                    Text("Forget password")
                        .underline()
                        .font(.system(size: footnote12))
                        .foregroundColor(.secondary)
                }
            }
            // FIXME: Cannot present alert
            .alert(isPresented: $alertPresented) {
                Alert(title: Text("Restore Password"),
                      message: Text("Please send an email using current email address to the contact email to restore your password."),
                      primaryButton: .default(Text("Send"), action:  { openURL(contactEmailURL) }),
                      secondaryButton: .cancel()
                )
            }
        }
    }
}
