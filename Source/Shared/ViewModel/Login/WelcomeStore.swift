//
//  WelcomeStore.swift
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
class WelcomeStore: ObservableObject {
    @Published var hollowSelection: Int? = nil
    @Published var isLoadingConfig = false
    @Published var errorMessage: (title: String, message: String)? = nil
    #if os(macOS) && !targetEnvironment(macCatalyst)
    @Published var showLogin = false
    #endif
    
    var cancellables = Set<AnyCancellable>()
    
    func requestConfig(hollowType: HollowType, customConfigURL: String? = nil) {
        
        // Validate the parameters
        if hollowType == .other {
            if customConfigURL == Constants.HollowConfig.thuConfigURL {
                errorMessage = (NSLocalizedString("WELCOMEVIEW_USING_IDENTICAL_CONFIG_ALERT_TITLE_PREFIX", comment: "") + "T大树洞" + NSLocalizedString("WELCOMEVIEW_USING_IDENTICAL_CONFIG_ALERT_TITLE_SUFFIX", comment: ""), "")
                return
            }
            if customConfigURL == Constants.HollowConfig.pkuConfigURL {
                errorMessage = (NSLocalizedString("WELCOMEVIEW_USING_IDENTICAL_CONFIG_ALERT_TITLE_PREFIX", comment: "") + "未名树洞" + NSLocalizedString("WELCOMEVIEW_USING_IDENTICAL_CONFIG_ALERT_TITLE_SUFFIX", comment: ""), "")
                return
            }
        }
        
        withAnimation {
            self.isLoadingConfig = true
        }
        
        let request = GetConfigRequest(configuration: GetConfigRequestConfiguration(hollowType: hollowType, customAPIRoot: customConfigURL)!)
        
        request.publisher
            .sinkOnMainThread(receiveCompletion: { completion in
                self.isLoadingConfig = false
                switch completion {
                case .failure(let error):
                    self.errorMessage = ("", error.description)
                case .finished: break
                }
            }, receiveValue: { result in
                self.isLoadingConfig = false
                Defaults[.hollowConfig] = result
                if hollowType == .other {
                    Defaults[.customConfigURL] = customConfigURL
                }
                withAnimation {
                    self.hollowSelection = hollowType.rawValue
                }
                #if os(macOS) && !targetEnvironment(macCatalyst)
                self.showLogin = true
                #endif
            })
            .store(in: &cancellables)
        
    }
}
