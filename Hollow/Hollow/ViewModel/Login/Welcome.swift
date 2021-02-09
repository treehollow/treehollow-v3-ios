//
//  Welcome.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/28.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import Defaults

/// View model for `WelcomeView`
class Welcome: ObservableObject {
    @Published var hollowSelection: Int? = nil
    @Published var isLoadingConfig = false
    @Published var errorMessage: (title: String, message: String)? = nil
    
    func requestConfig(hollowType: HollowType, customConfigURL: String? = nil) {
        
        // Validate the parameters
        if hollowType == .other {
            if customConfigURL == "" || customConfigURL == nil {
                errorMessage = (NSLocalizedString("Please input URL for your custom configuration", comment: ""), "")
                return
            }
            if customConfigURL == Constants.HollowConfig.thuConfigURL {
                errorMessage = (NSLocalizedString("You are using configuration for", comment: "") + " T大树洞. " + NSLocalizedString("Please choose the corresponding entry in 'Select Hollow'.", comment: ""), "")
                return
            }
            if customConfigURL == Constants.HollowConfig.pkuConfigURL {
                errorMessage = (NSLocalizedString("You are using configuration for", comment: "") + " 未名树洞. " + NSLocalizedString("Please choose the corresponding entry in 'Select Hollow'.", comment: ""), "")
                return
            }
        }
        
        withAnimation {
            self.isLoadingConfig = true
        }
        
        let request = GetConfigRequest(configuration: GetConfigRequestConfiguration(hollowType: hollowType, customAPIRoot: customConfigURL)!)
        
        request.performRequest { result, error in
            DispatchQueue.main.async {
                self.isLoadingConfig = false
            }
            if let error = error {
                debugPrint("Received error on loading config: \(error.description)")
                DispatchQueue.main.async {
                    switch error.errorType {
                    case .serverError, .other:
                        self.errorMessage = (String.errorLocalized.capitalized, error.description)
                    default:
                        if hollowType == .other {
                            self.errorMessage = (String.errorLocalized.capitalized, error.description)
                        } else {
                            self.errorMessage = (String.internalErrorLocalized.capitalized, error.description)
                        }
                    }
                }
                return
            }
            
            // Save to Defaults
            Defaults[.hollowConfig] = result!
            DispatchQueue.main.async {
                withAnimation {
                    self.hollowSelection = hollowType.rawValue
                }
            }
        }
        
    }
}
