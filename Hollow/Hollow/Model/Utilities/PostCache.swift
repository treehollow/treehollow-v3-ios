//
//  PostCache.swift
//  Hollow
//
//  Created by aliceinhollow on 2/20/21.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Cache

struct PostCache {
        
    var timestampStorage: Storage<Int, Int>?
    var postStorage: Storage<Int, PostData>?
    
    init() {
        
        self.timestampStorage = try? Storage<Int, Int>(
            diskConfig: DiskConfig(name: "HollowCommentsTimestamp"),
            memoryConfig: MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10),
            transformer: TransformerFactory.forCodable(ofType: Int.self)
        )
        
        self.postStorage = try? Storage<Int,PostData>(
            diskConfig: DiskConfig(name: "HollowComments"),
            memoryConfig: MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10),
            transformer: TransformerFactory.forCodable(ofType: PostData.self)
        )
    }
    
    /// find Timestamp using postID
    /// - Parameter postId: ID of post
    /// - Returns: timestamp  of post
    func getTimestamp(postId: Int) -> Int? {
        guard let timestamp = try? timestampStorage?.object(forKey: postId) else { return nil }
        return timestamp
    }
    
    /// Update Timestamp using postId and timestamp
    /// - Parameters:
    ///   - postId: postID
    ///   - timestamp: lastest updated timestamp for comments of postID
    func updateTimestamp(postId: Int, timestamp: Int) {
        try? timestampStorage?.setObject(timestamp, forKey: postId)
    }
    
    /// get PostData from cache
    /// - Parameter postId: postID
    /// - Returns: PostData from cache `nil` for not found
    func getPost(postId: Int) -> PostData? {
        guard let postData = try? postStorage?.object(forKey: postId) else { return nil }
        return postData
    }
    
    /// set PostData to cache
    /// - Parameters:
    ///   - postId: postID
    ///   - postdata: postData
    func updatePost(postId: Int, postdata: PostData) {
        try? postStorage?.setObject(postdata, forKey: postId)
    }
}
