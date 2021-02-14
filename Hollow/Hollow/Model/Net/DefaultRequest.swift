//
//  DefaultRequest.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/9.
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
/// The term `Default` means: normal and share some same attributes.
/// The protocol can apply to almost all requests.
///
/// # Associated type explained
/// - `Error == DefaultRequestError`
/// - `Result` should conform to `DefaultRequestResult`
/// - `Configuration` and `ResultData` can be any type
protocol DefaultRequest: Request where Error == DefaultRequestError, Result: DefaultRequestResult {
    
}

extension DefaultRequest {
    /// Default implementation of `performRequest`.
    /// - parameter urlPath: Path for HTTP request.
    /// - parameter parameters: Paramenters for the request. Use an empty [String : String] dictionary when there are no parameters.
    /// - parameter headers: HTTP headers to be included.
    /// - parameter method: `.post` or `.get`.
    /// - parameter resultToResultData: Method to generate result data from result.
    /// - parameter completion: Handler to call to handle returned data.
    internal func performRequest<Parameters: Encodable>(
        urlBase: [String],
        urlPath: String,
        parameters: [String : Parameters],
        headers: HTTPHeaders? = nil,
        method: HTTPMethod,
        resultToResultData: @escaping (Result) -> ResultData?,
        completion: @escaping (ResultData?, DefaultRequestError?) -> Void
    ) {
        // FIXME: need a auto switch alogorithm
        let urlRoot = urlBase[0]
        
        AF.request(
            urlRoot + urlPath,
            method: method,
            parameters: parameters.isEmpty ? nil : parameters,
            encoder: URLEncodedFormParameterEncoder.default,
            headers: headers
        )
        .validate()
        .responseJSON { response in
            print("[Request] \(self)")
            switch response.result {
            case .success:
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    guard let data = response.data else {
                        completion(nil, .unknown)
                        return
                    }
                    let result = try jsonDecoder.decode(Result.self, from: data)
                    print("[Result] \(result)")
                    
                    if result.code >= 0 {
                        // result code >= 0 valid!
                        if let resultData = resultToResultData(result) {
                            print("[Result Data] \(resultData)")
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
                print("[Request Error]: \(error.errorDescription ?? "not documented")")
                completion(nil, .other(description: error.localizedDescription))
            }
        }
    }

}
