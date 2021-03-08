//
//  CustomColorScheme.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/8.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

enum CustomColorScheme: Int, Codable, CustomStringConvertible, CaseIterable, Identifiable {
    case system
    case dark
    case light
    
    var id: Int { rawValue }
    
    var description: String {
        switch self {
        case .system: return NSLocalizedString("SETTINGS_CUSTOM_COLOR_SCHEME_SYSTEM", comment: "")
        case .light: return NSLocalizedString("SETTINGS_CUSTOM_COLOR_SCHEME_LIGHT", comment: "")
        case .dark: return NSLocalizedString("SETTINGS_CUSTOM_COLOR_SCHEME_DARK", comment: "")
        }
    }
}
