//
//  DefaultRequest.swift
//  Hollow
//
//  Created by 梁业升 on 2021/2/9.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Alamofire

protocol DefaultRequestResult: Codable {
    var code: Int { get }
    var msg: String? { get }
}

/// Protocol for default requests.
///
/// Associated type explained:
/// - `Error == DefaultRequestError`.
/// - `Result` should conform to `DefaultRequestResult`.
protocol DefaultRequest: Request where Error == DefaultRequestError, Result: DefaultRequestResult {
}

extension DefaultRequest {
    /// Default implementation of `performRequest`.
    /// - parameter urlPath: Path for HTTP request.
    /// - parameter parameters: Paramenters for the request.
    /// - parameter headers: HTTP headers to be included.
    /// - parameter method: `.post` or `.get`.
    /// - parameter resultToResultData: Method to generate result data from result.
    /// - parameter completion: Handler to call to handle returned data.
    func performRequest<Parameters: Encodable>(urlPath: String, parameters: [String : Parameters], headers: HTTPHeaders? = nil, method: HTTPMethod, resultToResultData: @escaping (Result) -> ResultData?, completion: @escaping (ResultData?, DefaultRequestError?) -> Void) {
        AF.request(
            urlPath,
            method: method,
            parameters: parameters,
            encoder: URLEncodedFormParameterEncoder.default,
            headers: headers
        ).validate().responseJSON { response in
            // TODO: print result in console.
            switch response.result {
            case .success:
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let result = try jsonDecoder.decode(Result.self, from: response.data!)
                    if result.code >= 0 {
                        // result code >= 0 valid!
                        if let resultData = resultToResultData(result) {
                            completion(resultData, nil)
                        } else {
                            completion(nil, .unknown)
                        }
                    } else {
                        completion(nil, .init(errorCode: result.code, description: result.msg))
                    }
                } catch {
                    completion(nil, .decodeFailed)
                    return
                }
            case let .failure(error):
                completion(nil, .other(description: error.localizedDescription))
            }
        }
    }

}
