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
            .onOpenURL { url in
                var urlString = url.absoluteString
                if urlString.prefix(15) == "HollowWidget://" || urlString.prefix(15) == "Hollow://post-#" {
                    urlString.removeSubrange(urlString.range(of: urlString.prefix(15))!)
                    if let postId = Int(urlString) {
                        IntegrationUtilities.openTemplateDetailView(postId: postId)
                    }
                }
            }
        }
    }
}
