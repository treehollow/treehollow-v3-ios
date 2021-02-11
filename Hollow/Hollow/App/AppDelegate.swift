//
//  AppDelegate.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/5.
//  Copyright © 2021 treehollow. All rights reserved.
//

import UIKit
import Defaults
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        #if DEBUG
//        Defaults[.accessToken] = nil
        Defaults[.hollowType] = .thu
        #endif
        
        // Request notification access
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { granted, error in
            guard granted else { return }
            
            // Register for APN
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }

        #if !DEBUG
        // Start AppCenter services
        AppCenter.start(
            withAppSecret: "aae3c20c-75f5-4840-96f3-541cd7e6dd88",
            services: [Analytics.self, Crashes.self]
        )
        #endif
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Temporarily save the token in defaults. We are not using this
        // default except registering or logging in for the first time.
        Defaults[.deviceToken] = deviceToken
        
        // Try to send the token to the server, if we have a user token.
        if let accessToken = Defaults[.accessToken] {
            sendDeviceToken(deviceToken, withAccessToken: accessToken)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        #if targetEnvironment(simulator)
        Defaults[.deviceToken] = "placeholder".data(using: .utf8)
        #endif
        print("Fail to register remote notification with error: \(error.localizedDescription)")
    }

    private func sendDeviceToken(_ deviceToken: Data, withAccessToken accessToken: String) {
        // TODO: Implementation
    }
}
