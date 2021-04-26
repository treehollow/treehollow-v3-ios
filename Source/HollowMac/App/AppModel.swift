//
//  AppModel.swift
//  HollowMac
//
//  Created by liang2kl on 2021/4/24.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Combine
import Defaults

class AppModel: ObservableObject {
    @Published var isInMainView = Defaults[.accessToken] != nil
}
