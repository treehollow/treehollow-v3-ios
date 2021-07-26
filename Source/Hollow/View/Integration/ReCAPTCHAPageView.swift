//
//  ReCAPTCHAPageView.swift
//  Hollow
//
//  Created by liang2kl on 2021/4/24.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import WebKit
import Defaults

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
                Image(systemName: "xmark")
                    .foregroundColor(.hollowContentText)
                    .dynamicFont(size: 20, weight: .medium)
                    .padding(.bottom)
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
                Spinner(color: .buttonGradient1, desiredWidth: 30)
            }
        })
        
    }
}

fileprivate struct ReCAPTCHAWebView: UIViewRepresentable {
    typealias UIViewType = WKWebView

    var onFinishLoading: () -> Void
    // TODO: Handler including parameter representing error.
    var successHandler: (String) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        return setupWebView(context: context)
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
    func setupWebView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.load(URLRequest(url: URL(string: Defaults[.hollowConfig]!.recaptchaUrl)!))
        webView.navigationDelegate = context.coordinator
        
        return webView
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: ReCAPTCHAWebView
        
        init(_ parent: ReCAPTCHAWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .other {
                if let urlString = navigationAction.request.url?.absoluteString,
                   let range = urlString.range(of: "recaptcha_token=") {
                    let key = urlString[range.upperBound...]
                    parent.successHandler(String(key))
                    webView.stopLoading()
                }
            }
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.onFinishLoading()
        }
    }
}
