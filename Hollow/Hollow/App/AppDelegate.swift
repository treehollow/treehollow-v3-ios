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
    // MARK: - UIApplicationDelegate
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        #if DEBUG
        // Perform test in test environment.
        // Add the modules you want to test in `options`.
        Test.performTest(options: [.getConfig])
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
        
        // Fetch the lastest config
        fetchConfig()
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

    // MARK: - Tree Hollow Configuration
    private func sendDeviceToken(_ deviceToken: Data, withAccessToken accessToken: String) {
        guard let config = Defaults[.hollowConfig] else { return }
        let configuration = UpdateDeviceTokenRequestConfiguration(deviceToken: deviceToken, token: accessToken, apiRoot: config.apiRootUrls)
        let request = UpdateDeviceTokenRequest(configuration: configuration)
        
        request.performRequest(completion: { result, error in
            if let _ = error {
                // TODO: Handle error
            }
        })
    }
    
    private func fetchConfig() {
        guard let hollowType = Defaults[.hollowType] else { return }
        var configURL: String? {
            switch hollowType {
            case .thu: return Constants.HollowConfig.thuConfigURL
            case .pku: return Constants.HollowConfig.pkuConfigURL
            case .other:
                return Defaults[.customConfigURL]
            }
        }
        
        guard let urlString = configURL else { return }
        let request = GetConfigRequest(configuration: GetConfigRequestConfiguration(hollowType: hollowType, customAPIRoot: urlString)!)
        
        request.performRequest(completion: { result, error in
            if let _ = error {
                // TODO: Handle error
                return
            }
            
            if let result = result {
                // Update the config
                Defaults[.hollowConfig] = result
            }
        })
    }
}
