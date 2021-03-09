//
//  SendVoteRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation
import Alamofire

struct SendVoteRequestConfiguration {
    var apiRoot: [String]
    var token: String
    var option: String
    var postId: Int
}

struct SendVoteRequestResult: DefaultRequestResult {
    var code: Int
    var msg: String?
    var vote: Vote?
}

typealias SendVoteRequestResultData = VoteData

struct SendVoteRequest: DefaultRequest {
    typealias Configuration = SendVoteRequestConfiguration
    typealias Result = SendVoteRequestResult
    typealias ResultData = SendVoteRequestResultData
    typealias Error = DefaultRequestError
    var configuration: SendVoteRequestConfiguration
    
    init(configuration: SendVoteRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (SendVoteRequestResultData?, DefaultRequestError?) -> Void) {
        let urlPath = "v3/send/vote" + Constants.Net.urlSuffix
        
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]
        
        let parameters: [String : Encodable] = [
            "option" : self.configuration.option,
            // type will be deprecated!
            "pid" : self.configuration.postId,
        ]
        performRequest(
            urlBase: self.configuration.apiRoot,
            urlPath: urlPath,
            parameters: parameters,
            headers: headers,
            method: .post,
            transformer: { $0.vote?.toVoteData() },
            completion: completion
        )
    }
}
