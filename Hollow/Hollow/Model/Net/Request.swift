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
    /// Type for data that view models use (see`/ViewModel/Types`).
    /// For example, for `Timeline`, `ResultData = [PostData]`
    associatedtype ResultData
    /// Configuration for the request, set via initializer.
    var configuration: Configuration { get }
    /// Handler to call after finish fetching data.
    var resultHandler: (ResultData) -> Void { get }
    /// - parameter configuration: Configuration for the request.
    /// - parameter resultHandler: Handler for handling the data that the request returns.
    init(configuration: Configuration, resultHandler: @escaping (ResultData) -> Void)
    /// Perform request and fetch the data, not initiating by the request itself.
    func performRequest()
}
