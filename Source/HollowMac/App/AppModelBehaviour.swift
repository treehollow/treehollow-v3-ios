//
//  AppModelBehaviour.swift
//  HollowMac
//
//  Created by liang2kl on 2021/4/24.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults
import UserNotifications

/// Modifier for views that take control of the behaviour of the app
/// using the model injected in the environment.
///
/// Supply `appModelState` (typically in the view model) to access **indirect**
/// control of the environment object in the view model.
struct AppModelBehaviour: ViewModifier {
    // Fetch the app model in the environment inside
    // this modifier to get rid of doing so in every view.
    @EnvironmentObject var appModel: AppModel
    
    var state: AppModelState
    
    func body(content: Content) -> some View {
        content
            // Use `onChange` to update the app model corresponding
            // to the internally stored state. Be careful that `onChange`
            // will be called when the state variable is initialized. So
            // remember to provide a correct initial value.
            
            // Handle entering main view
            .onChange(of: state.shouldShowMainView) { show in
                withAnimation { appModel.isInMainView = show }
                if !show { restore() }
            }
            
    }
    
    private func restore() {
        restoreDefaults()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    private func restoreDefaults() {
        Defaults.Keys.customConfigURL.reset()
        Defaults.Keys.accessToken.reset()
        Defaults.Keys.hiddenAnnouncement.reset()
        Defaults.Keys.deviceListCache.reset()
    }
}
