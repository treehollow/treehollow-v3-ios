//
//  HollowApp.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/5.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import WidgetKit

@main
struct HollowApp: App {
    // Receive delegate callbacks
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    
    // Singleton reflecting the actual state of the app.
    @StateObject var appModel = AppModel.shared
    @Environment(\.openURL) var openURL
    
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
#if targetEnvironment(macCatalyst)
            .environment(\.sizeCategory, .extraLarge)
#endif
            // Set the color scheme when appear
            .onAppear {
                IntegrationUtilities.setCustomColorScheme()
                WidgetCenter.shared.reloadAllTimelines()
            }
            // Fetch config when re-entering foreground
            .onReceive(
                NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification),
                perform: { _ in
                    appDelegate.fetchConfig()
                    if appModel.widgetReloadCount % 3 == 1 {
                        WidgetCenter.shared.reloadAllTimelines()
                        appModel.widgetReloadCount += 1
                    }
                }
            )
            .onOpenURL { appModel.handleURL($0, with: openURL) }
        }
    }
}
