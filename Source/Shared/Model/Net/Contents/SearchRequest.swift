//
//  SearchRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation
import HollowCore

typealias SearchRequestConfiguration = HollowCore.SearchRequestConfiguration

struct SearchRequest: DefaultConfigurationRequestAdaptor {
    typealias R = HollowCore.SearchRequest
    typealias Configuration = SearchRequestConfiguration
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
