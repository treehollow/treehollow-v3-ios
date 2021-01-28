//
//  GetConfigRequest.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/18.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Defaults
import Networking

/// config of GetConfig query
struct GetConfigRequestConfiguration {
    enum hollowName {
        case thuhole,pkuhollow,custom
    }
    /// hollow list
    var hollowName: hollowName
    /// custom hollow config
    var customAPIRoot: String?
    /// configAPIRoot
    var configUrl: String{
        switch self.hollowName {
        case .thuhole:
            return "https://cdn.jsdelivr.net/gh/treehollow/thuhole-config@master/config.txt"
        case .pkuhollow: return ""
        case .custom: return self.customAPIRoot!
        }
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
    // FIXME: existing ios frontend version
}

/// Get Config Request
class GetConfigRequest{//: Request {
    /// published var that UI used
    @Published var getConfigResult: GetConfigRequestResult?
    required init(configuration: GetConfigRequestConfiguration){
        /// chose config url
        let task = URLSession.shared.dataTask(with: URL(string: configuration.configUrl)!) { data, response, error in
            if let error = error {
                //self.handleClientError(error)
                /// FIXME: handle error
                debugPrint(error)
                return
                }
            guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                //self.handleServerError(response)
                /// FIXME : handle server error
                debugPrint(response!)
                return
                }
            if let mimeType = httpResponse.mimeType, mimeType == "text/plain",
                let data = data,
                let string = String(data: data, encoding: .utf8) {
                ///-----BEGIN TREEHOLLOW CONFIG-----
                ///-----END TREEHOLLOW CONFIG-----
                let apiInfo = string.components(separatedBy: "-----BEGIN TREEHOLLOW CONFIG-----")[1].components(separatedBy: "-----END TREEHOLLOW CONFIG-----")[0].data(using: .utf8)!
                let jsonDecoder = JSONDecoder()
                /// convert Snake Case
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                self.getConfigResult = try! jsonDecoder.decode(GetConfigRequestResult.self, from: apiInfo)
                debugPrint(self.getConfigResult!)
                /// getConfigResult stores content
            }
        }
        task.resume()
    }
}
