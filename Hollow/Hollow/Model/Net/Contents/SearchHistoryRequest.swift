//
//  SearchHistoryRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation

/// The configuration parameter is the user token
typealias SearchHistoryRequestConfiguration = String

struct SearchHistoryRequestResult {
    enum RequestType: Int {
        case success = 0
    }
    
    var type: RequestType
    var histories: [String]
}
