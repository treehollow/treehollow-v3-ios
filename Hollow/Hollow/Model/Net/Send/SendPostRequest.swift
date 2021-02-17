//
//  SendPostRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation
import Alamofire

struct SendPostRequestConfiguration {
    var apiRoot: [String]
    var token: String
    var text: String
    var tag: String?
    var imageData: Data?
    var voteData: [String]?
}

struct SendPostRequestResult: DefaultRequestResult {
    var code: Int
    var msg: String?
}

typealias SendPostRequestResultData = SendPostRequestResult

struct SendPostRequest: DefaultRequest {
    typealias Configuration = SendPostRequestConfiguration
    typealias Result = SendPostRequestResult
    typealias ResultData = SendPostRequestResultData
    typealias Error = DefaultRequestError

    var configuration: SendPostRequestConfiguration
    
    init(configuration: SendPostRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (SendPostRequestResultData?, DefaultRequestError?) -> Void) {
        let urlPath = "v3/send/post" + Constants.URLConstant.urlSuffix
        let hasImage = configuration.imageData != nil
        
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]

        var parameters: [String : Encodable] = [
            "text" : configuration.text,
            "type" : hasImage ? "image" : "text",
        ]

        if let imageData = configuration.imageData {
            parameters["data"] = imageData.base64EncodedString()
        }

        if let voteData = configuration.voteData {
            parameters["vote_options"] = voteData
        }

        if let tag = configuration.tag {
            parameters["tag"] = tag
        }
        
        performRequest(
            urlBase: configuration.apiRoot,
            urlPath: urlPath,
            parameters: parameters,
            headers: headers,
            method: .post,
            resultToResultData: { $0 },
            completion: completion
        )
    }
}
