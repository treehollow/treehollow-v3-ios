//
//  Request+publisher.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/24.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Combine

extension Request {
    /// The publisher for a single request.
    var publisher: RequestPublisher<Self> {
        return RequestPublisher(configuration: configuration)
    }
    
    /// Create a combined publisher for multiple asynchronous requests.
    /// - parameter requests: The requests to be performed asynchronously.
    /// - parameter retries: Retry number for each request.
    /// - returns: A merged publisher which never fails, where `output == (request_index, optional_output)`.
    /// If the `requests` array is empty, the return will be `nil`.
    ///
    /// For a series of independent requests, it is crucial to receive error message of specific request while letting other requests to continue.
    /// Thus we set `Failure` to `Never`, and replace `Output` from `ResultData` to a tuple of request's index and a wrapper for
    /// the data and the error (`OptionalOutput<ResultData, Error>`).
    ///
    /// When error occurs in any request, the output for this request is `(request_index, output_with_error)`,
    /// otherwise `(request_index, output_with_result_data)`.
    static func publisher(for requests: [Self], retries: Int = 0) -> AnyPublisher<(Int, OptionalOutput<ResultData, Error>), Never>? {
        typealias OutputWrapper = OptionalOutput<ResultData, Error>
        guard requests.count > 0 else { return nil }
        let pubilsher = requests[0].publisher
            .retry(retries)
            .map { OutputWrapper.success($0) }
            .catch { Just<OutputWrapper>(.failure($0)) }
            .map { (0, $0) }
            .eraseToAnyPublisher()
        if requests.count == 1 { return pubilsher }
        var mergedPublisher = pubilsher
        for index in 1..<requests.count {
            mergedPublisher = mergedPublisher
                .merge(with: requests[index].publisher
                        .retry(retries)
                        .map { OutputWrapper.success($0) }
                        .catch { Just<OutputWrapper>(.failure($0)) }
                        .map { (index, $0) }
                )
                .eraseToAnyPublisher()
        }
        return mergedPublisher
    }
}

enum OptionalOutput<R, E: Error> {
    case success(R)
    case failure(E)
}
