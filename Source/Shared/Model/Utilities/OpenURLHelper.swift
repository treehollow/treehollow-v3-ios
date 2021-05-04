//
//  OpenURLHelper.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/7.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct OpenURLHelper {
    enum OpenURLError: Error {
        case invalidURL
    }
    
    enum OpenMethod: Int, Codable, CaseIterable, Identifiable {
        case inApp
        case universal
        
        var id: Int { rawValue }
        
        var description: String {
            switch self {
            case .inApp: return NSLocalizedString("OPENURL_METHOD_IN_APP", comment: "")
            case .universal: return NSLocalizedString("OPENURL_METHOD_UNIVERSAL", comment: "")
            }
        }
    }
    
    var openURL: OpenURLAction
    
    #if !os(macOS) || targetEnvironment(macCatalyst)
    func tryOpen(_ url: URL, method: OpenMethod) throws {
        if UIApplication.shared.canOpenURL(url) {
            open(url, method: method)
        } else {
            if let newURL = URL(string: "https://" + url.absoluteString),
               UIApplication.shared.canOpenURL(newURL) {
                open(newURL, method: method)
            } else {
                throw OpenURLError.invalidURL
            }
        }
    }
    
    private func open(_ url: URL, method: OpenMethod) {
        switch method {
        case .inApp:
            IntegrationUtilities.presentSafariVC(url: url)
        case .universal:
            openURL(url)
        }
    }
    
    #else
    func tryOpen(_ url: URL, method: OpenMethod) throws {
        openURL(url)
    }
    #endif
    
}
