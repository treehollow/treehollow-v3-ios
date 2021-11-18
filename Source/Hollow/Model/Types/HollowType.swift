//
//  HollowType.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/28.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Defaults

enum HollowType: Int, Hashable, Identifiable, Codable, CaseIterable, DefaultsSerializable {
    var id: Int { rawValue }
    
    case thu = 1
    case pku = 2
    case other = 3
    var description: String {
        switch self {
        case .thu: return "thu"
        case .pku: return "pku"
        case .other: return "other"
        }
    }
    
    var name: String {
        switch self {
        case .thu: return "THU"
        case .pku: return "PKU"
        case .other: return NSLocalizedString("WELCOMEVIEW_OTHER", comment: "")
        }
    }

}
