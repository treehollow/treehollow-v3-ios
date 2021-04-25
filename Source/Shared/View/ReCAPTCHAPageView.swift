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
    let successHandler: (String) -> Void
    @State private var pageLoadingFinish = false

    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    presented = false
                }
            }) {
                #if !os(macOS)
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
            }, successHandler: successHandler)
            .onAppear {
                pageLoadingFinish = false
            }
        }
        .padding()
        .overlay(Group {
            if !pageLoadingFinish {
                #if !os(macOS)
                Spinner(color: .buttonGradient1, desiredWidth: 30)
                #else
                ProgressView("Loading")
                    .progressViewStyle(CircularProgressViewStyle())
                #endif
            }
        })
        
    }
}
