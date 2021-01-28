//
//  Login.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/28.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Combine
import Defaults

/// View model for `LoginView`
class Login: ObservableObject {
    func setHollowType(_ type: HollowType) {
        Defaults[.hollowType] = type
    }
}
