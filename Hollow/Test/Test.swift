//
//  Test.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/17.
//  Copyright © 2021 treehollow. All rights reserved.
//

#if DEBUG

import Foundation
import UIKit

struct Test {
    struct Options: OptionSet {
        let rawValue: Int
        static let getConfig = Options(rawValue: 1 << 0)
        static let getPush = Options(rawValue: 1 << 1)
        static let setPush = Options(rawValue: 1 << 2)
        static let deviceList = Options(rawValue: 1 << 3)
        static let updateDeviceToken = Options(rawValue: 1 << 4)
        static let emailCheck = Options(rawValue: 1 << 5)
        static let sendPost = Options(rawValue: 1 << 6)
        static let sendComment = Options(rawValue: 1 << 7)
        static let sendVoteData = Options(rawValue: 1 << 8)
    }
    
    static func performTest(options: Options = []) {
        if options.contains(.getConfig) {
            let request = GetConfigRequest(configuration: GetConfigRequestConfiguration(hollowType: .thu, customAPIRoot: nil)!)
            request.performTestRequest()
            
        }
        if options.contains(.sendComment) {
            let sendCommentRequest = SendCommentRequest(
                configuration: .init(
                    apiRoot: testAPIRoots,
                    token: testAccessToken,
                    text: "test reply to #1's #1 comment",
                    imageData: UIImage(named: "test")!.jpegData(compressionQuality: 1),
                    postId: 1,
                    replyCommentId: 1
                )
            )
            
            sendCommentRequest.performTestRequest()
        }
        if options.contains(.sendPost) {
            let sendPost = SendPostRequest(
                configuration: SendPostRequestConfiguration(
                    apiRoot: testAPIRoots,
                    token: testAccessToken,
                    text: "vote test",
                    tag: "",
                    imageData: UIImage(named: "test.2")!.jpegData(compressionQuality: 0.5)!,
                    voteData: ["a","b","c"]
                )
            )
            sendPost.performTestRequest()
        }
    }
}


extension Request {
    func performTestRequest() {
        performRequest(completion: { _, _ in })
    }
}

#endif
