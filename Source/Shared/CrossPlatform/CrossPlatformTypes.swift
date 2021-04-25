//
//  CrossPlatformTypes.swift
//  Hollow
//
//  Created by liang2kl on 2021/4/23.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
#if os(macOS)
typealias HImage = NSImage
typealias HView = NSView
typealias HColor = NSColor
#else
typealias HImage = UIImage
typealias HColor = UIColor
typealias HView = UIView
#endif
