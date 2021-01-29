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
    
    func requestConfig(hollowType: HollowType) {
        // Avoid setting .other in this view by mistake
        guard hollowType == .thu || hollowType == .pku else { fatalError() }
        withAnimation {
            self.isLoadingConfig = true
        }
        let request = GetConfigRequest(configuration: GetConfigRequestConfiguration(hollowType: hollowType, customAPIRoot: nil)!)
        request.performRequest { result, error in
            DispatchQueue.main.async {
                self.isLoadingConfig = false
            }
            if let error = error {
                debugPrint("Received error on loading config: \(error.description)")
                DispatchQueue.main.async {
                    switch error {
                    case .serverError, .other:
                        self.errorMessage = (NSLocalizedString("Error", comment: ""), error.description)
                    default:
                        self.errorMessage = (NSLocalizedString("Internal Error", comment: ""), error.description)
                    }
                }
                return
            }
            Defaults[.hollowConfig] = result!
            DispatchQueue.main.async {
                withAnimation {
                    self.hollowSelection = hollowType.rawValue
                }
            }
        }
    }
}
