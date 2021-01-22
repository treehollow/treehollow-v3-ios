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
    /// Type for data that view models use (see`/ViewModel/Types`), can be the same as `Result`.
    associatedtype ResultData
    /// Configuration for the request, set via initializer.
    var configuration: Configuration { get }
    /// - parameter configuration: Configuration for the request.
    init(configuration: Configuration)
    /// Handler for getting result from the server using the configuration, internal use.
    func getResult() -> Result?
    /// API for
    func getData() -> ResultData?
}
