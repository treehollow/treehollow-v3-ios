//
//  RequestAdaptor.swift
//  Hollow
//
//  Created by liang2kl on 2021/6/20.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import HollowCore
import Combine

/// Adapt `HollowCore` with the same old API.
///
/// In order to keep the old API that we provided to the view model, we need
/// this adaptor type to transform the APIs. It behaves the same as the old
/// `Request` protocol.
protocol RequestAdaptor {
    /// The underlying request type from `HollowCore`.
    associatedtype R: Request
    /// The old configuration type.
    associatedtype Configuration
    associatedtype FinalResult
    
    /// Init from old configuration.
    init(configuration: Configuration)
    /// Old configuration entry.
    var configuration: Configuration { get set }
    /// Transform the result from `HollowCore` to the old result data.
    func transformResult(_ result: R.ResultData) -> FinalResult
    /// Transform the old configuration to the one that `HollowCore` accepts.
    func transformConfiguration(_ configuration: Configuration) -> R.Configuration
}

extension RequestAdaptor {
    /// Perform request.
    func performRequest(completion: @escaping (FinalResult?, R.Error?) -> Void) {
        let config = transformConfiguration(configuration)
        R(configuration: config).performRequest {
            switch $0 {
            case .failure(let error):
                completion(nil, error)
            case .success(let data):
                completion(transformResult(data), nil)
            }
        }
    }
    
    /// Publisher that transform the original publisher.
    var publisher: AnyPublisher<FinalResult, R.Error> {
        let config = transformConfiguration(configuration)
        return R(configuration: config).publisher
            .map { transformResult($0) }
            .eraseToAnyPublisher()
    }
    
    static func publisher(for requests: [Self], retries: Int = 0) -> AnyPublisher<(Int, ResultType<FinalResult, R.Error>), Never>? {
        let _requests = requests.map { R(configuration: $0.transformConfiguration($0.configuration)) }
        let transformer: (Int, ResultType<R.ResultData, R.Error>) -> (Int, ResultType<FinalResult, R.Error>) = { index, result in
            return (index, result.map { result in requests[index].transformResult(result) })
        }
        return R.publisher(for: _requests, retries: retries)?
            .map(transformer)
            .eraseToAnyPublisher()
    }
}

extension RequestAdaptor {
    func result() async throws -> FinalResult {
        return try await withCheckedThrowingContinuation { continuation in
            performRequest(completion: { data, error in
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: DefaultRequestError.unknown)
                }
            })
        }
    }
}
