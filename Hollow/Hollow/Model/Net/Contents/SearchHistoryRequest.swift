//
//  SearchHistoryRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation

struct SearchHistoryRequest {
    enum RequestType: Int {
        case success = 0
    }
    
    var type: RequestType
    var histories: [String]
}
