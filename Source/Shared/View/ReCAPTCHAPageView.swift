//
//  ReCAPTCHAPageView.swift
//  Hollow
//
//  Created by liang2kl on 2021/4/24.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct ReCAPTCHAPageView: View {
    @Binding var presented: Bool
    var selfDismiss = false
    let successHandler: (String) -> Void
    @State private var pageLoadingFinish = false

    var body: some View {
        VStack {
            Button(action: {
                if selfDismiss { dismissSelf() }
                withAnimation {
                    presented = false
                }
            }) {
                #if !os(macOS) || targetEnvironment(macCatalyst)
                Image(systemName: "xmark")
                    .foregroundColor(.hollowContentText)
                    .dynamicFont(size: 20, weight: .medium)
                    .padding(.bottom)
                #else
                Text("Cancel")
                #endif

            }
            .keyboardShortcut(.cancelAction)

            .leading()
            ReCAPTCHAWebView(onFinishLoading: {
                withAnimation {
                    pageLoadingFinish = true
                }
            }, successHandler: {
                successHandler($0)
                if selfDismiss { dismissSelf() }
            })
            .onAppear {
                pageLoadingFinish = false
            }
        }
        .padding()
        .overlay(Group {
            if !pageLoadingFinish {
                #if !os(macOS) || targetEnvironment(macCatalyst)
                Spinner(color: .buttonGradient1, desiredWidth: 30)
                #else
                ProgressView("Loading")
                    .progressViewStyle(CircularProgressViewStyle())
                #endif
            }
        })
        
    }
}
