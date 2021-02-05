//
//  HollowApp.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/5.
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

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Defaults[.accessToken] = nil
        return true
    }
}
