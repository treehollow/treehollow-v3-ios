//
//  RandomListRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation
import Alamofire

typealias RandomListRequestConfiguration = PostListRequestConfiguration

typealias RandomListRequestResult = PostListRequestResult

typealias RandomListRequestResultData = [PostDataWrapper]

struct RandomListRequest: DefaultRequest {
    typealias Configuration = RandomListRequestConfiguration
    typealias Result = RandomListRequestResult
    typealias ResultData = RandomListRequestResultData
    typealias Error = DefaultRequestError
    
    var configuration: RandomListRequestConfiguration
    
    init(configuration: RandomListRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (RandomListRequestResultData?, DefaultRequestError?) -> Void) {
        let urlPath = "v3/contents/post/randomlist" + Constants.URLConstant.urlSuffix
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]
        let parameters = [String : Encodable]()
        
        let transformer: (RandomListRequestResult) -> RandomListRequestResultData? = { result in
            guard let resultData = result.data else { return nil }
            var postWrappers = [PostDataWrapper]()
            postWrappers = resultData.map { post in
                return PostDataWrapper(
                    post: post.toPostData(comments: [CommentData]()),
                    citedPost: nil
                )
            }

            return postWrappers
        }
        
        performRequest(
            urlBase: self.configuration.apiRoot,
            urlPath: urlPath,
            parameters: parameters,
            headers: headers,
            method: .get,
            transformer: transformer,
            completion: completion
        )
    }
}
