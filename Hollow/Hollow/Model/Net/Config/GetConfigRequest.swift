//
//  GetConfigRequest.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/18.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

/// config of GetConfig query
struct GetConfigRequestConfiguration {
    /// hollow list
    var hollowType: HollowType
    /// custom hollow config
    var customAPIRoot: String?
    /// configAPIRoot
    var configUrl: String {
        switch self.hollowType {
        case .thu:
            return Constants.HollowConfig.thuConfigURL
        case .pku: return Constants.HollowConfig.pkuConfigURL
        case .other: return self.customAPIRoot!
        }
    }
    
    init?(hollowType: HollowType, customAPIRoot: String?) {
        // If using custom config without valid APIRoot, return nil
        if hollowType == .other && customAPIRoot == nil { return nil }
        self.hollowType = hollowType
        self.customAPIRoot = customAPIRoot
    }
}

/// Result of requesting system config.
typealias HollowConfig = GetConfigRequestResult
struct GetConfigRequestResult: Codable {
    var name: String
    var recaptchaUrl: String
    var allowScreenshot: Bool
    var apiRoot: String
    var tosUrl: String
    var privacyUrl: String
    var contactEmail: String
    var emailSuffixes: [String]
    var announcement: String
    var foldTags: [String]
    var reportableTags: [String]
    var sendableTags: [String]
    var imgBaseUrl: String
    var imgBaseUrlBak: String
    var websocketUrl: String
    var iosFrontendVersion: String
}

/// GetConfigRequestError
struct GetConfigRequestError: RequestError {
    
    typealias ErrorType = GetConfigRequestErrorType
    var errorType: GetConfigRequestErrorType
    
    enum GetConfigRequestErrorType {
        case serverError
        case decodeFailed
        case incorrectFormat
        case invalidConfigUrl
        case invalidConfiguration
        case other(description: String)
    }
    
    var description: String {
        switch self.errorType {
        case .serverError: return "Received error from the server."
        case .decodeFailed: return "Fail to decode tree hollow configuration from the URL."
        case .incorrectFormat: return "The format of the tree hollow configuration is incorrect."
        case .invalidConfigUrl: return "The URL for the configuration is invalid."
        case .invalidConfiguration: return "The configuration is invalid."
        case .other(let description): return description
        }
    }
}

/// Get Config Request
struct GetConfigRequest: Request {
    typealias Configuration = GetConfigRequestConfiguration
    typealias Result = GetConfigRequestResult
    typealias ResultData = Result   // same as the result
    typealias Error = GetConfigRequestError
    
    var configuration: GetConfigRequestConfiguration
    
    init(configuration: GetConfigRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (ResultData?, GetConfigRequestError?) -> Void) {
        guard let url = URL(string: configuration.configUrl) else {
            completion(nil, GetConfigRequestError(errorType: .invalidConfigUrl))
            return
        }
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, GetConfigRequestError(errorType: .other(description: error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(nil, GetConfigRequestError(errorType: .serverError))
                return
            }
            
            guard let mimeType = httpResponse.mimeType, mimeType == "text/plain",
                  let data = data,
                  let string = String(data: data, encoding: .utf8) else {
                completion(nil, GetConfigRequestError(errorType: .incorrectFormat))
                return
            }
            
            let components1 = string.components(separatedBy: "-----BEGIN TREEHOLLOW CONFIG-----")
            if components1.count == 2 {
                let component2 = components1[1].components(separatedBy: "-----END TREEHOLLOW CONFIG-----")
                if component2.count >= 1, let apiInfo = component2[0].data(using: .utf8) {
                    // finally match the format, then process it
                    let jsonDecoder = JSONDecoder()
                    // convert Snake Case
                    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let result = try jsonDecoder.decode(Result.self, from: apiInfo)
                        if validateConfig(result) {
                            // Call the callback
                            completion(result, nil)
                        } else {
                            completion(nil,GetConfigRequestError(errorType: .invalidConfigUrl))
                        }
                    } catch {
                        completion(nil, GetConfigRequestError(errorType: .decodeFailed))
                    }
                    return
                }
                
            }
            
            // Cannot match the format
            completion(nil, GetConfigRequestError(errorType: .incorrectFormat))
        }
        task.resume()
    }
    
    private func validateConfig(_ config: GetConfigRequestResult) -> Bool {
        return
            config.apiRoot != "" &&
            config.emailSuffixes.count > 0 &&
            config.imgBaseUrl != "" &&
            config.name != "" &&
            config.recaptchaUrl != ""
    }
}
