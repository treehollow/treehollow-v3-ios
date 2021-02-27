//
//  HollowApp.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/5.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults
import Connectivity

@main
struct HollowApp: App {
    // Receive delegate callbacks
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    
    // Singleton reflecting the actual state of the app.
    @StateObject var appModel = AppModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appModel.isInMainView {
                    MainView()
                } else {
                    WelcomeView()
                }
            }
            // inject the app model into the environment
            .environmentObject(appModel)
        }
    }
}