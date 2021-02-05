//
//  AppDelegate.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import UIKit
import Defaults

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Request notification access
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { granted, error in
            guard granted else { return }
            
            // Register for APN
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
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
        print("Fail ro register remote notification with error: \(error.localizedDescription)")
    }

    private func sendDeviceToken(_ deviceToken: Data, withAccessToken accessToken: String) {
        // TODO: Implementation
    }
}

