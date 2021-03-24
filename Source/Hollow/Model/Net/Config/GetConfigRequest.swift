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
typealias GetConfigRequestResult = HollowConfig

/// GetConfigRequestError
enum GetConfigRequestError: RequestError {
    case serverError
    case decodeFailed
    case incorrectFormat
    case invalidConfigUrl
    case invalidConfiguration
    case loadingCompleted
    case other(description: String)
    
    var description: String {
        switch self {
        case .serverError: return NSLocalizedString("REQUEST_GET_CONFIG_ERROR_SERVER_ERROR", comment: "")
        case .decodeFailed: return NSLocalizedString("REQUEST_GET_CONFIG_ERROR_DECODE_FAILED", comment: "")
        case .incorrectFormat: return NSLocalizedString("REQUEST_GET_CONFIG_ERROR_INCORRECT_FORMAT", comment: "")
        case .invalidConfigUrl: return NSLocalizedString("REQUEST_GET_CONFIG_ERROR_INVALID_URL", comment: "")
        case .invalidConfiguration: return NSLocalizedString("REQUEST_GET_CONFIG_ERROR_INVALID_CONFIG", comment: "")
        case .loadingCompleted: return ""
        case .other(let description): return description
        }
    }
    
    func loadingCompleted() -> Bool {
        switch self {
        case .loadingCompleted: return true
        default: return false
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
            completion(nil, .invalidConfigUrl)
            return
        }
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, .other(description: error.localizedDescription))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(nil, .serverError)
                return
            }
            
            guard let mimeType = httpResponse.mimeType, mimeType == "text/plain",
                  let data = data,
                  let string = String(data: data, encoding: .utf8) else {
                completion(nil, .incorrectFormat)
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
                        
                        if GetConfigRequest.validateConfig(result) {
                            // Call the callback
                            completion(result, nil)
                        } else {
                            completion(nil, .invalidConfigUrl)
                        }
                    } catch {
                        completion(nil, .decodeFailed)
                    }
                    return
                }
                
            }
            
            // Cannot match the format
            completion(nil, .incorrectFormat)
        }
        task.resume()
    }
    
    static private func validateConfig(_ config: GetConfigRequestResult) -> Bool {
        return
            config.apiRootUrls != [] &&
            config.emailSuffixes.count > 0 &&
            config.imgBaseUrls != [] &&
            config.name != "" &&
            config.recaptchaUrl != "" &&
            config.tosUrl != "" &&
            config.privacyUrl != "" &&
            config.rulesUrl != ""
    }   
}
