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
    @State var reCAPTCHAToken: String = ""
    @State private var pageLoadingFinish = false
    @State private var confirmedPassword = ""
    
    var body: some View {
        VStack {
            let configuration = Defaults[.hollowConfig]!
            MyTextField(text: $viewModel.email, placeHolder: .emailAddressAllCapitalized, title: NSLocalizedString("Enter Your Email", comment: "")) {
                return Menu(content: {
                    ForEach(0..<configuration.emailSuffixes.count) { index in
                        Button(configuration.emailSuffixes[index], action: {
                            viewModel.emailSuffix = configuration.emailSuffixes[index]
                        })
                    }
                }, label: {
                    Text("@" + viewModel.emailSuffix).font(.system(size: 14))
                })
            }
            
            if viewModel.emailCheckType == .newUser {
                MyTextField<EmptyView>(text: $viewModel.emailVerificationCode, title: .emailVerificationCodeAllCapitalized)
                MyTextField<EmptyView>(text: $viewModel.originalPassword, title: .passWordCapitalized)
                MyTextField<EmptyView>(text: $confirmedPassword, title: .confirmedPassWordCapitalized)
            }
            
            MyButton(action: {
                viewModel.checkEmail()
            }, gradient: .vertical(gradient: .button)) {
                Text(LocalizedStringKey("Continue"))
            }
        }
        .fullScreenCover(isPresented: $viewModel.reCAPTCHAPresented, content: {
            ReCAPTCHAPageView(presented: $viewModel.reCAPTCHAPresented, token: $viewModel.reCAPTCHAToken)
        })
        .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
            // We should restore the error message after presenting the alert
            Alert(title: Text(viewModel.errorMessage!.title), message: Text(viewModel.errorMessage!.message), dismissButton: .default(Text(LocalizedStringKey("OK")), action: { viewModel.errorMessage = nil }))
        }
    }
}

extension LoginView {
    private struct ReCAPTCHAPageView: View {
        @Binding var presented: Bool
        @Binding var token: String
        @State private var pageLoadingFinish = false
        
        var body: some View {
            VStack {
                Button(action: {
                    withAnimation {
                        presented = false
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
                }, successHandler: { token in
                    withAnimation {
                        self.token = token
                        presented = false
                    }
                })
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
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
