//
//  LoginView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/17.
//

import SwiftUI
import Defaults

struct LoginView: View {
    @ObservedObject var viewModel: Login = .init()
    @State private var password = ""
    @State private var fullScreenCover: Int = -1
    
    /// Determine when we should check user's email.
    ///
    /// This value is `true` when email check hasn't been performed yet,
    /// or the return code is indicating `reCAPTCHANeeded`.
    private var shouldCheckEmail: Bool { viewModel.emailCheckType == nil || viewModel.emailCheckType == .reCAPTCHANeeded }
    
    // TODO: Handle invalid code
    /// Determine when we should present the reCAPTCHA verification interface.
    ///
    /// This value is `true` when we has checked that this email should register after a reCAPTCHA verification
    /// and we don't have a token yet.
    private var shouldShowReCAPTCHA: Bool { viewModel.emailCheckType == .reCAPTCHANeeded && viewModel.reCAPTCHAToken == "" }
    
    /// Determine when the user should register with verification code and password.
    ///
    /// This value is `true` only when the return code indicates `newUser`.
    private var shouldRegister: Bool {
        viewModel.emailCheckType == .newUser
    }
    
    /// Determine when the user should enter the password to login.
    ///
    /// This value is `true` only when the return code indicates `oldUser`.
    private var shouldLogin: Bool { viewModel.emailCheckType == .oldUser }
    
    private var buttonText: String {
        if viewModel.isLoading { return String.loadingLocalized.capitalized + "..." }
        if shouldCheckEmail { return String.continueLocalized.capitalized }
        if shouldRegister { return String.registerLocalized.capitalized }
        if shouldLogin { return String.loginLocalized.capitalized }
        if shouldShowReCAPTCHA { return String.continueLocalized.capitalized }
        return ""
    }
    
    private var disableInteraction: Bool { viewModel.isLoading }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    let configuration = Defaults[.hollowConfig]!
                    
                    // Enter email text field
                    MyTextField(text: $viewModel.email, placeHolder: NSLocalizedString("Enter your email", comment: ""), title: String.emailAddressLocalized.firstLetterUppercased) {
                        // Accessory view for selecting email suffix
                        return Menu(content: {
                            ForEach(0..<configuration.emailSuffixes.count) { index in
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
                            .font(.system(size: 14))
                        })
                    }
                    .padding(.top)
                    
                    if shouldRegister {
                        RegisterView(viewModel: viewModel)
                    }
                    
                    if shouldLogin {
                        MyTextField<EmptyView>(text: $viewModel.loginPassword, placeHolder: NSLocalizedString("Enter your password", comment: ""), title: String.passwordLocalized.capitalized, isSecureContent: true)
                    }
                    
                }
                .disabled(disableInteraction)
            }

            MyButton(action: {
                if shouldCheckEmail { viewModel.checkEmail() }
                if shouldRegister { viewModel.register() }
                if shouldLogin { viewModel.login() }
            }, gradient: .vertical(gradient: .button),
            transitionAnimation: .default,
            cornerRadius: 12) {
                HStack {
                    Text(buttonText)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(8)
                        .horizontalCenter()
                }
            }
            .disabled(disableInteraction)
            
        }
        .padding(.horizontal)
        .padding(.horizontal)
        
        .fullScreenCover(isPresented: .constant(viewModel.fullScreenCoverIndex != -1), content: {
            Group {
                // Present reCAPTCHA verification interface when needed
                if viewModel.fullScreenCoverIndex == 0 {
                    ReCAPTCHAPageView(presentedIndex: $viewModel.fullScreenCoverIndex, successHandler: { token in
                        withAnimation {
                            viewModel.fullScreenCoverIndex = -1
                            viewModel.reCAPTCHAToken = token
                            // Check again with the token
                            viewModel.checkEmail()
                        }
                    })
                }
                
                // Present main view after successfully logging in
                if viewModel.fullScreenCoverIndex == 1 {
                    MainView()
                }
            }
        })
        
        // Show alert if there's any error message provided
        .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
            // We should restore the error message after presenting the alert
            Alert(title: Text(viewModel.errorMessage!.title), message: Text(viewModel.errorMessage!.message), dismissButton: .default(Text(LocalizedStringKey("OK")), action: { viewModel.errorMessage = nil }))
        }
        
        .navigationTitle(Defaults[.hollowConfig]!.name)
        .background(Color.background.edgesIgnoringSafeArea(.all))
    }
}

extension LoginView {
    private struct ReCAPTCHAPageView: View {
        @Binding var presentedIndex: Int
        let successHandler: (String) -> Void
        @State private var pageLoadingFinish = false
        
        var body: some View {
            VStack {
                Button(action: {
                    withAnimation {
                        presentedIndex = -1
                    }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.plainButton)
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
                Text(LocalizedStringKey("reCAPTCHA verification needed"))
                    .font(.footnote)
                    .padding(.bottom, 5)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .overlay(Group {
                if !pageLoadingFinish {
                    Spinner(color: .buttonGradient1, desiredWidth: 30)
                }
            })

        }
    }
    
    private struct RegisterView: View {
        @ObservedObject var viewModel: Login
        
        //    private var passwordValidate: Bool { Constants.Register.passwordRegex.firstMatch(in: viewModel.originalPassword, range: NSRange(viewModel.originalPassword)!) != nil }
        private var passwordValid: Bool { true }
        private var confirmedPasswordValid: Bool { viewModel.confirmedPassword == viewModel.originalPassword }

        private let passwordRequirements: String =
            NSLocalizedString("Requirements", comment: "") + ":\n" +
            NSLocalizedString("at least one digit", comment: "") + "\n" +
            NSLocalizedString("at least one lowercase character", comment: "") + "\n" +
            NSLocalizedString("at least one uppercase character", comment: "") + "\n" +
            NSLocalizedString("at least one special character", comment: "") + "\n" +
            NSLocalizedString("at least 8 characters in length, but no more than 32", comment: "")

        var body: some View {
            // Verification code text field
            MyTextField<EmptyView>(text: $viewModel.emailVerificationCode, title: String.emailVerificationCodeLocalized.capitalized, footer: NSLocalizedString("Please check your inbox.", comment: ""))
                .keyboardType(.numberPad)
            
            // Password text field
            MyTextField(text: $viewModel.originalPassword, title: String.passWordLocalized.capitalized, footer: passwordRequirements, isSecureContent: true) {
                Group {
                    if viewModel.originalPassword != "" && !passwordValid {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                    } else if viewModel.originalPassword != "" {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                }
                .font(.system(size: 15))
            }
            
            // Confirmed password text field
            MyTextField(text: $viewModel.confirmedPassword, title: String.confirmedPassWordLocalized.capitalized, isSecureContent: true) {
                Group {
                    if viewModel.confirmedPassword != "" && !confirmedPasswordValid {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                    } else if viewModel.confirmedPassword != "" {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                }
                .font(.system(size: 15))
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
