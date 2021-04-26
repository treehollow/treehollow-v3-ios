//
//  UIDevice+isPad.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import UIKit

extension UIDevice {
    static let isPad = UIDevice.current.userInterfaceIdiom == .pad
    #if targetEnvironment(macCatalyst)
    static let isMac = true
    #else
    static let isMac = false
    #endif
}
