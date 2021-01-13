//
//  CustomWebView.swift
//  THU-Hole
//
//  Created by 梁业升 on 2021/1/13.
//

import SwiftUI
import WebKit

final class CustomWebView: UIViewRepresentable {
    var htmlString: String
    
    init(htmlString: String) {
        self.htmlString = htmlString
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.loadHTMLString(htmlString, baseURL: nil)
        webView.backgroundColor = nil
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
}
