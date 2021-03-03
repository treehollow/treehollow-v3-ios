//
//  SystemMessage.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import Foundation

/// Data representation of a system message
struct SystemMessage: Codable, Identifiable {
    var id: Double { timestamp.timeIntervalSince1970 }
    /// message content
    var content: String
    /// unix time stamp of this message
    var timestamp: Date
    /// message title
    var title: String
}

