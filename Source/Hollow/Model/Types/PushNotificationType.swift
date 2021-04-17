//
//  PushNotificationType.swift
//  Hollow
//
//  Created by aliceinhollow on 7/2/2021.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

struct PushNotificationType: Codable, Equatable {
    // Set default value
    var pushSystemMsg: Bool = true
    var pushReplyMe: Bool = true
    var pushFavorited: Bool = false
    
    // Helper enum used to enumerate through all the cases.
    enum Enumeration: Int, CaseIterable, Identifiable, CustomStringConvertible {
        case pushSystemMsg
        case pushReplyMe
        case pushFavorited
        
        var id: Int { rawValue }
        
        var keyPath: WritableKeyPath<PushNotificationType, Bool> {
            switch self {
            case .pushFavorited: return \.pushFavorited
            case .pushReplyMe: return \.pushReplyMe
            case .pushSystemMsg: return \.pushSystemMsg
            }
        }
        
        var description: String {
            switch self {
            case .pushFavorited: return NSLocalizedString("PUSH_NOTIFICATION_TYPE_FAVOURITE", comment: "")
            case .pushReplyMe: return NSLocalizedString("PUSH_NOTIFICATION_TYPE_REPLY_ME", comment: "")
            case .pushSystemMsg: return NSLocalizedString("PUSH_NOTIFICATION_TYPE_SYSTEM_MSG", comment: "")
            }
        }
    }
}

