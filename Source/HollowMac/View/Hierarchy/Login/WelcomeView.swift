//
//  WelcomeView.swift
//  HollowMac
//
//  Created by liang2kl on 2021/4/24.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

struct WelcomeView: View {
    @ObservedObject var store = WelcomeStore()
    
    var body: some View {
        VStack(spacing: 20) {
            Image(nsImage: NSApp.applicationIconImage)
                .padding(50)
            Text(Constants.Application.appLocalizedName)
                .bold()
                .font(.title2)
                .padding(.bottom, 20)
            Spacer()
            Button(action: {
                Defaults[.hollowType] = .thu
                Defaults[.hollowConfig] = nil
                store.requestConfig(hollowType: .thu)
            }) {
                Text("T大树洞").frame(minWidth: 80)
            }
            
            Button(action: {
                Defaults[.hollowType] = .pku
                Defaults[.hollowConfig] = nil
                store.requestConfig(hollowType: .pku)
            }) {
                Text("未名树洞").frame(minWidth: 80)
            }

            Button(action: {
                Defaults[.customConfigURL] = nil
                Defaults[.hollowType] = .other
                Defaults[.hollowConfig] = nil
                showInputAlert(
                    title: NSLocalizedString("WELCOMEVIEW_INPUT_CUSTOM_URL_ALERT_TITLE", comment: ""),
                    message: NSLocalizedString("WELCOMEVIEW_INPUT_CUSTOM_URL_ALERT_MSG", comment: ""),
                    placeholder: "https://example.com/config.txt",
                    onDismiss: { url in if let url = url {
                        store.requestConfig(hollowType: .other, customConfigURL: url)
                    }}
                )
            }) {
                Text("其他").frame(minWidth: 80)
            }
        }
        .padding(.bottom)
        .disabled(store.isLoadingConfig)
        .frame(minWidth: 300, maxWidth: 600)
        .sheet(isPresented: $store.showLogin) {
            LoginView()
        }
        .navigationTitle("Welcome")
        .errorAlert($store.errorMessage)

    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
