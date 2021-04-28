//
//  ReCAPTCHAWebView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/28.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import WebKit
import Defaults

#if os(macOS)
fileprivate typealias HViewRepresentable = NSViewRepresentable
#else
fileprivate typealias HViewRepresentable = UIViewRepresentable
#endif

struct ReCAPTCHAWebView: HViewRepresentable {
    #if os(macOS)
    typealias NSViewType = WKWebView
    #else
    typealias UIViewType = WKWebView
    #endif
    var onFinishLoading: () -> Void
    // TODO: Handler including parameter representing error.
    var successHandler: (String) -> Void
    
    #if os(macOS)
    func makeNSView(context: Context) -> WKWebView {
        return setupWebView(context: context)
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
    }
    #else
    func makeUIView(context: Context) -> WKWebView {
        return setupWebView(context: context)
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    #endif
    
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