//
//  PostDetail.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import Foundation
import Alamofire
import Cache

struct PostDetailRequestConfiguration {
    var apiRoot: [String]
    var imageBaseURL: [String]
    var token: String
    var postId: Int
    /// if this param is given and there's no new comment, the return code would
    /// be 1 (`.successWithNoNewComment`), while comments and post would be none.
    // dont need to pass this
    // var oldUpdateTimestamp: Int?
}

struct PostDetailRequestResult: DefaultRequestResult {
    var code: Int
    var msg: String?
    var post: Post?
    var data: [Comment]?
}

struct PostDetailRequestResultData {
    enum ResultType: Int {
        case success = 0
        case successWithNoNewComment = 1
    }
    
    var type: ResultType
    var postWrap: PostDataWrapper
}

struct PostDetailRequest: DefaultRequest {
    
    typealias Configuration = PostDetailRequestConfiguration
    typealias Result = PostDetailRequestResult
    typealias ResultData = PostDetailRequestResultData
    typealias Error = DefaultRequestError
    
    var configuration: PostDetailRequestConfiguration
    
    init(configuration: PostDetailRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (PostDetailRequestResultData?, DefaultRequestError?) -> Void) {
        let urlPath = "v3/contents/post/detail" + Constants.URLConstant.urlSuffix
        let headers: HTTPHeaders = [
            "TOKEN": self.configuration.token,
            "Accept": "application/json"
        ]
        var parameters: [String : String] = [
            "pid" : configuration.postId.string
        ]
        
        let commentsTimestamp: Storage<Int, Int>
        
        if let oldupdated = self.configuration.oldUpdateTimestamp {
            parameters["old_updated_at"] = oldupdated.string
        }
        
        performRequest(urlBase: configuration.apiRoot,
                       urlPath: urlPath,
                       method: .get,
                       resultToResultData: { result in
                        if let post = result.post, let comments = result.data {
                            // postdetail dont need cited post
                            var postWrapper = PostDataWrapper(post: post.toPostData(comments: comments.map{ $0.toCommentData() }), citedPost: nil)
                            completion(PostDetailRequestResultData(type: post.updatedAt == oldupdated ? .success : .successWithNoNewComment, postWrap: postWrapper),nil)
                        }
                       },
                       completion: completion)
    }
    
}
