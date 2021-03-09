//
//  ViewConstants.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/4.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

/// Namespace for shared constants used in views.
struct ViewConstants {
    /// Standard spacing for VStack in customized lists (e.g. login / register fields)
    static let listVStackSpacing: CGFloat = 25
    /// Width for spinner shown as navigation item.
    static let navigationBarSpinnerWidth: CGFloat = 17
    /// Font size for a bordered, small, textual button.
    static let plainButtonFontSize: CGFloat = 13
    /// Colors to use in avatars.
    static let avatarTintColors: [Color] = (1...16).map({ Color("avatar." + String($0)) })
    
    static let inputViewVStackSpacing: CGFloat = 12
}
