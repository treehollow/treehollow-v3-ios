//
//  Request.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/19.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

/// Protocol for HTTP request types.
protocol Request {
    /// Configuration type.
    associatedtype Configuration
    /// Result type for the request, get directly from the server.
    associatedtype Result
    /// Type for data that view models use (see`/ViewModel/Types`), can be the same as `Result`
    /// ~~for async request it returns a publisher~~
    /// It is the type for the associated `Output` type of the publisher.
    associatedtype ResultData
    /// Configuration for the request, set via initializer.
    var configuration: Configuration { get }
    /// - parameter configuration: Configuration for the request.
    init(configuration: Configuration)
    
    // TODO: API for returning a publisher
}
