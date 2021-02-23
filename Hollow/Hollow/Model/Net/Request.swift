//
//  Request.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/19.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Combine

/// Protocol for HTTP request types.
protocol Request {
    /// Configuration type.
    associatedtype Configuration
    /// Result type for the request, get directly from the server.
    associatedtype Result
    /// Type for data that view models use (see`/Model/Types`).
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

extension Request {
    /// The publisher for a single request.
    var publisher: RequestPublisher<Self> {
        return RequestPublisher(configuration: configuration)
    }
    
    /// Create a combined publisher for multiple requests which never fails.
    /// - parameter requests: The requests to be performed asynchronously.
    /// - parameter retries: Retry number for each request.
    /// - returns: A merged published which never fails, where `output == (request_index, optional_result_data)`.
    ///
    /// When error occurs in any request, the output is `(request_index, nil)`, otherwise `(request_index, result_data)`.
    static func publisher(for requests: [Self], retries: Int = 0) -> AnyPublisher<(Int, ResultData?), Never>? {
        guard requests.count > 0 else { return nil }
        let pubilsher = requests[0].publisher
            .retry(retries)
            .nullable()
            .replaceError(with: nil)
            .map { (0, $0) }
            .eraseToAnyPublisher()
        if requests.count == 1 { return pubilsher }
        var mergedPublisher = pubilsher
        for index in 1..<requests.count {
            mergedPublisher = mergedPublisher
                .merge(with: requests[index].publisher
                        .retry(retries)
                        .nullable()
                        .replaceError(with: nil)
                        .map({ (index, $0) })
                )
                .eraseToAnyPublisher()
        }
        return mergedPublisher
    }
}
