//
//  HollowMacApp.swift
//  HollowMac
//
//  Created by liang2kl on 2021/4/24.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

@main
struct HollowMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var appModel = AppModel()
    
    init() {
        Defaults[.accessToken] = nil
    }

    var body: some Scene {
        WindowGroup {
            if appModel.isInMainView {
                
            } else {
                WelcomeView()
//                    .disabled(appModel.isLoggingIn)
                    .environmentObject(appModel)
            }
            
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowToolbarStyle(ExpandedWindowToolbarStyle())
    }
}
