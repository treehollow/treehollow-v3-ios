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
    var openURL: OpenURLAction
    
    func tryOpen(_ url: URL) throws {
        if UIApplication.shared.canOpenURL(url) {
            openURL(url)
        } else {
            if let newURL = URL(string: "https://" + url.absoluteString),
               UIApplication.shared.canOpenURL(newURL) {
                openURL(newURL)
            } else {
                throw OpenURLError.invalidURL
            }
        }
    }
}
