//
//  ReportRequestGroup.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/5.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Combine

enum ReportRequestGroupConfiguration {
    case post(ReportPostRequestConfiguration)
    case comment(ReportCommentRequestConfiguration)
}

struct ReportRequestGroupResult: DefaultRequestResult {
    var code: Int
    var msg: String?
}


struct ReportRequestGroup: DefaultRequest {
    
    typealias Configuration = ReportRequestGroupConfiguration
    typealias Result = ReportRequestGroupResult
    typealias ResultData = ReportRequestGroupResult
    typealias Error = DefaultRequestError
    
    var configuration: ReportRequestGroupConfiguration
    
    init(configuration: ReportRequestGroupConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (ReportRequestGroupResult?, DefaultRequestError?) -> Void) {
        switch configuration {
        case .post(let configuration):
            ReportPostRequest(configuration: configuration).performRequest(completion: completion)
        case .comment(let configuration):
            ReportCommentRequest(configuration: configuration).performRequest(completion: completion)
        }
    }
}
