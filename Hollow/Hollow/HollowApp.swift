//
//  HollowApp.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/5.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

@main
struct HollowApp: App {
    // Receive delegate callbacks
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            if let _ = Defaults[.accessToken] {
                MainView()
            } else {
                WelcomeView()
            }
        }
    }
}
