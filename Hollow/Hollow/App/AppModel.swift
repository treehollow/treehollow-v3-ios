//
//  AppModel.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/15.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Combine
import Defaults

class AppModel: ObservableObject {
    @Published var errorMessage: (title: String, message: String)?
    @Published var inMainView = Defaults[.accessToken] != nil
}
