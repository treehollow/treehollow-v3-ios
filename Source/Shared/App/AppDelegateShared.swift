//
//  AppDelegateShared.swift
//  HollowMac
//
//  Created by liang2kl on 2021/4/24.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults
import UserNotifications
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

#if os(macOS)
typealias HAppDelegate = AppDelegate
typealias HApplication = NSApplication
#else
typealias HAppDelegate = AppDelegate
typealias HApplication = UIApplication
#endif

extension HAppDelegate {
    func setupApplication(_ application: HApplication) {
        #if !DEBUG
        // Start AppCenter services
        AppCenter.start(
            withAppSecret: "aae3c20c-75f5-4840-96f3-541cd7e6dd88",
            services: [Analytics.self, Crashes.self]
        )
        #endif
        
        // Setup remote notifications
        setupRemoteNotifications(application)
        
        // Fetch the lastest config
        fetchConfig()
    }
    
    func didRegisterForRemoteNotifications(with deviceToken: Data) {
        // Temporarily save the token in defaults. We are not using this
        // default except registering or logging in for the first time.
        Defaults[.deviceToken] = deviceToken
        
        // Try to send the token to the server, if we have a user token.
        if let accessToken = Defaults[.accessToken] {
            sendDeviceToken(deviceToken, withAccessToken: accessToken)
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

    func fetchConfig() {
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

    func setupRemoteNotifications(_ application: HApplication) {
        // Request notification access
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        let authorizationOptions = Constants.Application.requestedNotificationOptions
        center.requestAuthorization(options: authorizationOptions) { granted, error in
            guard granted else { return }
            // Register for APN
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
}

extension HAppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let content = response.notification.request.content
        
        if let type = content.userInfo["type"] as? Int, type == 1 {
            // System message for type 1
            presentMessageView()
        } else if let postId = content.userInfo["pid"] as? Int {
            let commentId = content.userInfo["cid"] as? Int
            presentDetail(postId: postId, commentId: commentId)
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        if notification.request.content.userInfo["delete"] == nil {
            completionHandler([.banner, .sound, .list])
        } else {
            completionHandler([])
        }
    }
    
    
}

#if os(macOS)
extension AppDelegate {
    // TODO: Implementation
    private func presentDetail(postId: Int, commentId: Int?) {
    }
    
    private func presentMessageView() {
    }
}
#else
extension AppDelegate {
    private func presentDetail(postId: Int, commentId: Int?) {
        IntegrationUtilities.openTemplateDetailView(postId: postId, jumpToComment: commentId)
    }
    
    private func presentMessageView() {
        let messageView = MessageView(presented: .constant(true), page: .message, selfDismiss: true)
        IntegrationUtilities.presentView(content: { messageView })
    }
}

#endif
