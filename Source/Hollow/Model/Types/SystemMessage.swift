//
//  SystemMessage.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import Foundation

/// Data representation of a system message
struct SystemMessage: Codable, Identifiable {
    var id: Int { timestamp }
    /// message content
    var content: String
    /// unix time stamp of this message
    var timestamp: Int
    /// message title
    var title: String
    
    var date: Date { Date(timeIntervalSince1970: TimeInterval(timestamp)) }
}

