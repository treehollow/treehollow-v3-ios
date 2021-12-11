//
//  AccountInfoView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI
import Combine
import Defaults

struct AccountInfoView: View {
    @ObservedObject var viewModel = AccountInfoStore()
    @State private var logoutAlertPresented = false
    var body: some View {
        List {
            Section {
                NavigationLink(NSLocalizedString("DEVICELISTVIEW_NAV_TITLE", comment: ""), destination: DeviceListView())
            }
            Section {
                NavigationLink(
                    NSLocalizedString("ACCOUNTINFOVIEW_CHANGE_PASSWORD_CELL_LABEL", comment: ""),
                    destination: ChangePasswordView().environmentObject(viewModel)
                )
                
                #if !targetEnvironment(macCatalyst)
                NavigationLink(NSLocalizedString("LOGINVIEW_RESTORE_PASSWORD_ALERT_UNREGISTER_BUTTON", comment: ""), destination: UnregisterView())
                #endif
            }
            
            Section {
                Button("ACCOUNTVIEW_LOGOUT_BUTTON", action: {
                    #if targetEnvironment(macCatalyst)
                    // Not presenting alert as there're bugs with this.
                    viewModel.logout()
                    #else
                    logoutAlertPresented = true
                    #endif
                })
                    .foregroundColor(.red)
            }
            
        }
        .navigationBarTitle(NSLocalizedString("ACCOUNTVIEW_ACCOUNT_CELL", comment: ""))
        .defaultListStyle()
        .modifier(LoadingIndicator(isLoading: viewModel.isLoading))
        .modifier(ErrorAlert(errorMessage: $viewModel.errorMessage))
        .disabled(viewModel.isLoading)
        .styledAlert(
            presented: $logoutAlertPresented,
            title: NSLocalizedString("ACCOUNTVIEW_LOGOUT_ALERT_TITLE", comment: ""),
            message: NSLocalizedString("ACCOUNTVIEW_FORCE_LOGOUT_MSG", comment: ""),
            buttons: [
                .init(
                    text: NSLocalizedString("ACCOUNTVIEW_LOGOUT_BUTTON", comment: ""),
                    style: .destructive,
                    action: { viewModel.logout() }
                ),
                .init(
                    text: NSLocalizedString("ACCOUNTVIEW_FORCE_LOGOUT_BUTTON", comment: ""),
                    style: .destructive,
                    action: { viewModel.logout(force: true) }
                ),
                .cancel
            ]
        )
    }
}

extension AccountInfoView {
    struct ChangePasswordView: View {
        @EnvironmentObject var viewModel: AccountInfoStore
        @State private var email: String = ""
        @State private var originalPassword = ""
        @State private var newPassword = ""
        @State private var confirmedPassword = ""
        var contentInvalid: Bool {
            if viewModel.isLoading { return false }
            return originalPassword == "" ||
            newPassword == "" ||
            newPassword.count < 8 || newPassword.contains(" ") ||
            email == "" ||
            newPassword != confirmedPassword
        }
        var body: some View {
            List {
                Section {
                    TextField(text: $email, prompt: "CHANGEPASSWORDVIEW_ENTER_EMAIL_PLACEHOLDER")
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                }
                
                SecureField(text: $originalPassword, prompt: "CHANGEPASSWORDVIEW_ENTER_ORI_PASSWORD_PLACEHOLDER")

                Section(footer: Text("LOGINVIEW_PASSWORD_TEXTFIELD_REQUIREMENT_FOOTER")) {
                    HStack {
                        SecureField(text: $newPassword, prompt: "CHANGEPASSWORDVIEW_ENTER_NEW_PASSWORD_PLACEHOLDER")
                        if (newPassword.count < 8 && !newPassword.isEmpty) || newPassword.contains(" ") {
                            Image(systemName: "xmark")
                                .foregroundColor(.red)
                        }
                    }
                    HStack {
                        SecureField(text: $confirmedPassword, prompt: "CHANGEPASSWORDVIEW_CONFIRM_PASSWORD_PLACEHOLDER")
                        if confirmedPassword != newPassword && confirmedPassword != "" {
                            Image(systemName: "xmark")
                                .foregroundColor(.red)
                        }
                    }
                }
                Button("CHANGEPASSWORDVIEW_SUBMMIT_BUTTON") {
                    viewModel.changePassword(for: email, original: originalPassword, new: newPassword)
                }
                .disabled(contentInvalid)
            }
            .navigationBarTitle(NSLocalizedString("ACCOUNTINFOVIEW_CHANGE_PASSWORD_CELL_LABEL", comment: ""))
            .defaultListStyle()
            .modifier(ErrorAlert(errorMessage: $viewModel.errorMessage))
            .modifier(LoadingIndicator(isLoading: viewModel.isLoading))
            .disabled(viewModel.isLoading)
        }
    }
}
