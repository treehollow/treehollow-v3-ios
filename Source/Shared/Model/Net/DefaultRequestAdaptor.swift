//
//  DefaultRequestAdaptor.swift
//  Hollow
//
//  Created by 梁业升 on 2021/6/20.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import HollowCore

// MARK: - Protocols

/// `RequestAdaptor` with the same configuration type as the underlying `Request`.
protocol DefaultConfigurationRequestAdaptor: RequestAdaptor where Configuration == R.Configuration {}

extension DefaultConfigurationRequestAdaptor {
    func transformConfiguration(_ configuration: Configuration) -> R.Configuration {
        return configuration
    }
}

/// `RequestAdaptor` with the same result type as the underlying `Request`.
protocol DefaultResultRequestAdaptor: RequestAdaptor where FinalResult == R.ResultData {}

extension DefaultResultRequestAdaptor {
    func transformResult(_ result: R.ResultData) -> FinalResult {
        return result
    }
}

/// `RequestAdaptor` with the same configuration and result type as the underlying `Request`.
protocol DefaultRequestAdaptor: DefaultConfigurationRequestAdaptor, DefaultResultRequestAdaptor {}


// MARK: - Generic Implementations: Very Powerful!

struct PostListGenericRequest<_R: Request>: DefaultConfigurationRequestAdaptor where _R.ResultData == [PostWrapper] {
    typealias R = _R
    typealias Configuration = _R.Configuration
    typealias FinalResult = [PostDataWrapper]
    
    var configuration: Configuration
    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    func transformResult(_ result: [PostWrapper]) -> [PostDataWrapper] {
        return result.map { $0.toPostDataWrapper() }
    }
}

struct DefaultGenericRequest<_R: Request>: DefaultRequestAdaptor {
    typealias R = _R
    typealias Configuration = _R.Configuration
    typealias FinalResult = _R.ResultData
    
    var configuration: _R.Configuration
    
    init(configuration: _R.Configuration) {
        self.configuration = configuration
    }
}
