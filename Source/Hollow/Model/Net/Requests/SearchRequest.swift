//
//  SearchRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation
import HollowCore

struct SearchRequest: DefaultConfigurationRequestAdaptor {
    typealias R = HollowCore.SearchRequest
    typealias Configuration = HollowCore.SearchRequest.Configuration
    typealias FinalResult = [PostDataWrapper]
//
    init(configuration: HollowCore.SearchRequest.Configuration) {
        self.configuration = configuration
    }

    var configuration: HollowCore.SearchRequest.Configuration
    
    func transformResult(_ result: [PostWrapper]) -> [PostDataWrapper] {
        return result.map { $0.toPostDataWrapper() }
    }
}
