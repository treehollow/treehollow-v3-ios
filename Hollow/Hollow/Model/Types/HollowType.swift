//
//  HollowType.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/28.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

enum HollowType: Int, Hashable, Identifiable, Codable {
    var id: Int { rawValue }
    
    case thu, pku, other
    var description: String {
        switch self {
        case .thu: return "thu"
        case .pku: return "pku"
        case .other: return "other"
        }
    }
}
