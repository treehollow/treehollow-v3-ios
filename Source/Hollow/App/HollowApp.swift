//
//  HollowApp.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/5.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

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
                    if UIDevice.isPad {
                        MainView_iPad()
                    } else {
                        MainView()
                    }
                } else {
                    WelcomeView()
                }
            }
            // Set larger size category for macOS
            .conditionalSizeCategory()
            // Inject the app model into the environment
            .environmentObject(appModel)
            // Set the color scheme when appear
            .onAppear { IntegrationUtilities.setCustomColorScheme() }
            // Chcek for version update
            .onReceive(
                UpdateAvailabilityRequest.defaultPublisher,
                perform: VersionUpdateUtilities.handleUpdateAvailabilityResult
            )
            // Fetch config when re-entering foreground
            .onReceive(
                NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification),
                perform: { _ in appDelegate.fetchConfig() }
            )
        }
    }
}
