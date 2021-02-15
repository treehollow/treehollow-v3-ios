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
    
    @ScaledMetric(wrappedValue: ViewConstants.navigationBarSpinnerWidth) var spinnerWidth

    // Determine when we should check user's email.
    private var shouldCheckEmail: Bool { viewModel.emailCheckType == nil || viewModel.emailCheckType == .reCAPTCHANeeded }
    
    // Determine when the user should register with verification code and password.
    private var shouldRegister: Bool { viewModel.emailCheckType == .newUser }
    
    // Determine when the user should enter the password to login.
    private var shouldLogin: Bool { viewModel.emailCheckType == .oldUser }
    
    private var buttonText: String {
        if viewModel.isLoading { return String.loadingLocalized.capitalized + "..." }
        if shouldCheckEmail { return String.continueLocalized.capitalized }
        if shouldRegister { return String.registerLocalized.capitalized }
        if shouldLogin { return String.loginLocalized.capitalized }
        return ""
    }
    
    // Determine when to disable the interaction with the text fields
    private var disableInteraction: Bool { viewModel.isLoading }
    
    // Determine when to disable the button
    private var disableButton: Bool {
        if viewModel.isLoading { return true }
        if shouldCheckEmail { return viewModel.email == "" }
        if shouldRegister { return
            viewModel.emailVerificationCode == "" ||
            viewModel.confirmedPassword != viewModel.originalPassword ||
            // Invalid original password
            viewModel.originalPassword.count < 8 ||
            viewModel.originalPassword.contains(" ")
        }
        if shouldLogin { return viewModel.loginPassword == "" }
        return true
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: ViewConstants.listVStackSpacing) {
                    // Enter email text field
                    EmailTextField(viewModel: viewModel)
                        .padding(.top)
                    
                    // Text fields for entering register information
                    if shouldRegister {
                        RegisterTextFields(viewModel: viewModel)
                    }
                    
                    // Login text field
                    if shouldLogin {
                        LoginTextField(viewModel: viewModel)
                    }
                    
                }
                .disabled(disableInteraction)
            }
            
            // Button
            ExpandedButton(
                action: {
                    if shouldCheckEmail { viewModel.checkEmail() }
                    if shouldRegister { viewModel.register() }
                    if shouldLogin { viewModel.login() }
                },
                transitionAnimation: .default,
                text: buttonText
            )
            .disabled(disableButton)
            
        }
        .padding(.horizontal)
        .padding(.horizontal)
        .padding(.bottom)
        
        // Display spinner on navigation bar while loading.
        .navigationBarItems(trailing: Group {
            if viewModel.isLoading {
                Spinner(color: .hollowContentText,
                        desiredWidth: spinnerWidth)
            }
        })
        
        // Present full screen content when there is a need (reCAPTCHA verification / main interface).
        .fullScreenCover(isPresented: $viewModel.showsRecaptcha) {
            ReCAPTCHAPageView(
                presented: $viewModel.showsRecaptcha,
                successHandler: { token in
                    withAnimation {
                        viewModel.showsRecaptcha = false
                        viewModel.reCAPTCHAToken = token
                        // Check again with the token
                        viewModel.checkEmail()
                    }
                }
            )
        }
        
        // Show alert if there's any error message provided
        .modifier(ErrorAlert(errorMessage: $viewModel.errorMessage))
        
        .navigationTitle(Defaults[.hollowConfig]!.name)
        .background(Color.background.edgesIgnoringSafeArea(.all))
        
        // Take control of the app.
        .modifier(AppModelBehaviour(state: viewModel.state))
    }
}

#if DEBUG
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
#endif
