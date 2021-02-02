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
    
    private var showsRegisterComponents: Bool {
        viewModel.emailCheckType == .newUser ||
            (viewModel.emailCheckType == .reCAPTCHANeeded && viewModel.reCAPTCHAToken != "")
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    let configuration = Defaults[.hollowConfig]!
                    MyTextField(text: $viewModel.email, placeHolder: NSLocalizedString("Enter your email", comment: ""), title: String.emailAddressLocalized.firstLetterUppercased) {
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
                    
                    if showsRegisterComponents {
                        MyTextField<EmptyView>(text: $viewModel.emailVerificationCode, title: String.emailVerificationCodeLocalized.capitalized)
                        MyTextField<EmptyView>(text: $viewModel.originalPassword, title: String.passWordLocalized.capitalized, isSecureContent: true)
                        MyTextField<EmptyView>(text: $confirmedPassword, title: String.confirmedPassWordLocalized.capitalized, isSecureContent: true)
                            .textContentType(.password)
                    }
                }
            }
//            Spacer()
            MyButton(action: {
                viewModel.checkEmail()
            }, gradient: .vertical(gradient: .button),
            transitionAnimation: .default,
            cornerRadius: 12) {
                Text(String.loginLocalized.capitalized)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(8)
                    .horizontalCenter()
            }
        }
        .padding(.horizontal)
        .padding(.horizontal)
        .fullScreenCover(isPresented: $viewModel.reCAPTCHAPresented, content: {
            ReCAPTCHAPageView(presented: $viewModel.reCAPTCHAPresented, token: $viewModel.reCAPTCHAToken)
        })
        .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
            // We should restore the error message after presenting the alert
            Alert(title: Text(viewModel.errorMessage!.title), message: Text(viewModel.errorMessage!.message), dismissButton: .default(Text(LocalizedStringKey("OK")), action: { viewModel.errorMessage = nil }))
        }
        .navigationTitle(String.loginLocalized.capitalized)
        .background(Color.background.edgesIgnoringSafeArea(.all))
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
