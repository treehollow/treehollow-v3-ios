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
    associatedtype ResultData
    /// Request error comforming to `RequestError` protocol
    associatedtype Error: RequestError
    
    /// Configuration for the request, set via initializer.
    var configuration: Configuration { get }
    /// - parameter configuration: Configuration for the request.
    init(configuration: Configuration)
    /// Perform request and fetch the data.
    func performRequest(completion: @escaping (ResultData?, Error?) -> Void)
}

protocol RequestError: Error {
    // TODO: Localization
    var description: String { get }
}

/// DefaultRequestError for default request
public enum DefaultRequestError: RequestError {
    case decodeError
    case other(description: String)
    var description: String {
        switch self {
        case .decodeError: return "Fail to decode tree hollow configuration from the URL."
        case .other(let description): return description
        }
    }
}
