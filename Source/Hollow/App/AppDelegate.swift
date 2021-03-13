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
import Connectivity
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    // MARK: - UIApplicationDelegate
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        #if DEBUG
        
        // Perform test in test environment.
        // Add the modules you want to test in `options`.
        Test.performTest(options: [])
        #else
        
        // Start AppCenter services
        AppCenter.start(
            withAppSecret: "aae3c20c-75f5-4840-96f3-541cd7e6dd88",
            services: [Analytics.self, Crashes.self]
        )
        
        #endif
        
        Defaults[.customColorSet] = Defaults[.tempCustomColorSet]
        Defaults[.tempCustomColorSet] = nil
        Defaults[.applyCustomColorSet] = Defaults[.customColorSet] != nil
        
        // Setup remote notifications
        setupRemoteNotifications(application)
        
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
        print("Fail to register remote notification with error: \(error.localizedDescription)")
    }
    
}

// MARK: - Tree Hollow Configuration
extension AppDelegate {
    func setupRemoteNotifications(_ application: UIApplication) {
        // Request notification access
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options:[.badge, .alert, .sound]) { granted, error in
            guard granted else { return }
            
            // Register for APN
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
    
    private func sendDeviceToken(_ deviceToken: Data, withAccessToken accessToken: String) {
        guard let config = Defaults[.hollowConfig] else { return }
        let configuration = UpdateDeviceTokenRequestConfiguration(deviceToken: deviceToken, token: accessToken, apiRoot: config.apiRootUrls)
        let request = UpdateDeviceTokenRequest(configuration: configuration)
        
        request.performRequest(completion: { result, error in
            if let error = error {
                print(error)
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
                // Update the config and test connectivity
                Defaults[.hollowConfig] = result
                LineSwitchManager.testAll()
            }
        })
    }
}

// MARK: - User Notifications
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let content = response.notification.request.content
        if let postId = content.userInfo["pid"] as? Int {
            let commentId = content.userInfo["cid"] as? Int
            presentDetail(postId: postId, commentId: commentId)
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    func presentDetail(postId: Int, commentId: Int?) {
        guard let topVC = IntegrationUtilities.topViewController() else { return }
        let postDataWrapper = PostDataWrapper.templatePost(for: postId)
        let detailView = HollowDetailView(store: .init(bindingPostWrapper: .constant(postDataWrapper), jumpToComment: commentId))
        let vc = UIHostingController(rootView: detailView)
        vc.modalPresentationStyle = .popover
        topVC.present(vc, animated: true)
    }
}
