//
//  AppDelegate.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/5.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - UIApplicationDelegate
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Defaults[.customColorSet] = Defaults[.tempCustomColorSet]
        Defaults[.applyCustomColorSet] = Defaults[.customColorSet] != nil
        setupApplication(application)
        let appearance = UITableView.appearance(whenContainedInInstancesOf: [HollowDetailViewController.self, HollowDetailViewController_iPad.self])
        appearance.backgroundColor = UIColor(Color.hollowCardBackground)
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        didRegisterForRemoteNotifications(with: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
    
    #if targetEnvironment(macCatalyst)
    override func buildMenu(with builder: UIMenuBuilder) {
        builder.remove(menu: .file)
        builder.remove(menu: .edit)
        builder.remove(menu: .format)
        builder.remove(menu: .help)
        builder.remove(menu: .services)
        builder.remove(menu: .toolbar)
    }
    #endif
}
