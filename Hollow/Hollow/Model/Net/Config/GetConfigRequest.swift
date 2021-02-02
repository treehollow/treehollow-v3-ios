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
            return "https://cdn.jsdelivr.net/gh/treehollow/thuhole-config@master/config.txt"
        case .pku: return ""
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

/// Result of requesting system config. as following
/*
 {"name":"T大树洞","recaptcha_url":"https://id.thuhole.com/recaptcha/","allow_screenshot":true,"api_root":"https://dev-api.thuhole.com/","tos_url":"https://thuhole.com/tos.html","privacy_url":"https://thuhole.com/privacy.html","contact_email":"contact@thuhole.com","email_suffixes":["mails.tsingua.edu.cn"],"announcement":"这里是测试服","fold_tags":["性相关","政治相关","NSFW","刷屏","引战","未经证实的传闻","令人不适","重复内容","举报较多"],"reportable_tags":["性相关","政治相关","NSFW","刷屏","引战","未经证实的传闻","令人不适","重复内容"],"sendable_tags":["性相关","政治相关","NSFW","刷屏","引战","未经证实的传闻","令人不适"],"img_base_url":"https://dev-img.thuhole.com/","img_base_url_bak":"https://dev-img2.thuhole.com/","web_frontend_version":"v2.2.0","android_frontend_version":"v0.0.0","android_apk_download_url":"https://example.com/","ios_frontend_version":"v0.0.0","websocket_url":"https://dev-ws.thuhole.com/v3/ws"}
 */
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
    var urlSuffix: String?
}

/// Get Config Request
struct GetConfigRequest: Request {
    typealias Configuration = GetConfigRequestConfiguration
    typealias Result = GetConfigRequestResult
    typealias ResultData = Result   // same as the result
    typealias Error = GetConfigRequestError
    
    enum GetConfigRequestError: RequestError {
        case serverError
        case decodeFailed
        case incorrectFormat
        case invalidConfigUrl
        case other(description: String)
        
        var description: String {
            switch self {
            case .serverError: return "Received error from the server."
            case .decodeFailed: return "Fail to decode tree hollow configuration from the URL."
            case .incorrectFormat: return "The format of the tree hollow configuration is incorrect."
            case .invalidConfigUrl: return "The URL for the configuration is invalid."
            case .other(let description): return description
            }
        }
    }
    
    var configuration: GetConfigRequestConfiguration
    
    init(configuration: GetConfigRequestConfiguration) {
        self.configuration = configuration
        // Not performing request here, let the view model initiate
        // the request using `performRequest` instead.
    }
    
    func performRequest(completion: @escaping (ResultData?, GetConfigRequestError?) -> Void) {
        guard let url = URL(string: configuration.configUrl) else {
            completion(nil, .invalidConfigUrl)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, .other(description: error.localizedDescription))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(nil, GetConfigRequestError.serverError)
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
                        var result = try jsonDecoder.decode(GetConfigRequestResult.self, from: apiInfo)
                        // Add urlSuffix for using
                        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                        result.urlSuffix = "?v=v\(appVersion)&device=2"
                        debugPrint(result)
                        // Call the callback
                        completion(result, nil)
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
}
