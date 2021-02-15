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
    
    /// Singleton reflecting the actual state of the app.
    @ObservedObject var appModel = AppModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                // FIXME: Should use one var
                if appModel.inMainView {
                    MainView()
                } else {
                    WelcomeView()
                }
            }
            // inject the app model into the environment
            .environmentObject(appModel)
//            .modifier(ErrorAlert(errorMessage: $appModel.errorMessage))
        }
    }
}
