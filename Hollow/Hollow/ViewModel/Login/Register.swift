//
//  Register.swift
//  Hollow
//
//  Created by 梁业升 on 2021/1/28.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Combine
import Foundation

/// View model for `RegisterView`
class Register: ObservableObject {
    @Published var reCAPTCHAKey: String = ""
}
