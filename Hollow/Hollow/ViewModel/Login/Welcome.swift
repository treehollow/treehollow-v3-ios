//
//  Welcome.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/28.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Combine
import Defaults

/// View model for `WelcomeView`
class Welcome: ObservableObject {
    var config: GetConfigRequestResult? = nil
    
    func requestConfig(hollowType: HollowType) {
        // Avoid setting .other in this view by mistake
        guard hollowType == .thu || hollowType == .pku else { fatalError() }
        let request = GetConfigRequest(configuration: GetConfigRequestConfiguration(hollowType: hollowType, customAPIRoot: nil)!)
        request.performRequest { result, error in
            if let error = error {
                debugPrint(error.description)
//                switch error {
//                // TODO: do something
//                case .decodeFailed:
//                    break
//                case .serverError:
//                    break
//                }
                return
            } else {
                self.config = result!
                Defaults[.hollowConfig] = result!
            }
        }
    }
}
