//
//  CustomConfigConfigurationViewModel.swift
//  Hollow
//
//  Created by 梁业升 on 2021/1/30.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import SwiftUI
import Defaults

class CustomConfigConfigurationViewModel: ObservableObject {
    @Published var configURL: String = ""
}
