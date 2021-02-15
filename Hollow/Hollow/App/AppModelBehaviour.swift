//
//  AppModelBehaviour.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/15.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

/// Modifier for views that take control of the behaviour of the app
/// using the model injected in the environment.
///
/// Supply `state` (typically in the view model) to access **indirect**
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
            
            // Handle global error message
            .onChange(of: state.errorMessage?.message) { message in
                guard message != nil else { return }
                withAnimation { appModel.errorMessage = state.errorMessage }
            }
        
            // Handle entering main view
            .onChange(of: state.shouldShowMainView) { show in
                withAnimation { appModel.inMainView = show }
            }
    }
}
