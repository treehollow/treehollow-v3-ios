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
        
        let resultToResultData: (RandomListRequestResult) -> RandomListRequestResultData? = { result in
            guard let resultData = result.data else { return nil }
            var postWrappers = [PostDataWrapper]()
            postWrappers = resultData.map{ post in
                return PostDataWrapper(
                    post: post.toPostData(comments: [CommentData]()),
                    citedPost: nil
                )
            }
            
            // return no citedPost and image here
            completion(postWrappers,nil)
            // no need for citedPost
            
            // start loading image
            for index in postWrappers.indices {
                // image in post
                if let url = postWrappers[index].post.hollowImage?.imageURL {
                    ImageDownloader.downloadImage(
                        urlBase: self.configuration.imageBaseURL,
                        urlString: url,
                        imageCompletionHandler: { image in
                            if let image = image {
                                postWrappers[index].post.hollowImage?.image = image
                                completion(postWrappers, nil)
                            } else {
                                // report image loading fail
                                completion(postWrappers,.imageLoadingFail(postID: postWrappers[index].post.id))
                            }
                        }
                    )
                }
            }
            
            return postWrappers
        }
        
        performRequest(
            urlBase: self.configuration.apiRoot,
            urlPath: urlPath,
            parameters: parameters,
            headers: headers,
            method: .get,
            resultToResultData: resultToResultData,
            completion: completion
        )
    }
}
