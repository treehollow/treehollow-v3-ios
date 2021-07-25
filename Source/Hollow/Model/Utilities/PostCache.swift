//
//  PostCache.swift
//  Hollow
//
//  Created by aliceinhollow on 2/20/21.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Cache
import HollowCore

struct PostCache {
    
    static let shared = PostCache()
    
    var postStorage: Storage<Int, PostWrapper>?
    
    private init() {
        
        self.postStorage = try? Storage<Int,PostWrapper>(
            diskConfig: DiskConfig(name: "HollowComments"),
            memoryConfig: MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10),
            transformer: TransformerFactory.forCodable(ofType: PostWrapper.self)
        )
    }
    
    /// get PostData from cache
    /// - Parameter postId: postID
    /// - Returns: PostData from cache `nil` for not found
    func getPost(postId: Int) -> PostWrapper? {
        guard let postData = try? postStorage?.object(forKey: postId) else { return nil }
        return postData
    }
    
    /// set PostData to cache
    /// - Parameters:
    ///   - postId: postID
    ///   - postdata: postData
    func updatePost(postId: Int, postWrapper: PostWrapper) {
        try? postStorage?.setObject(postWrapper, forKey: postId)
    }
    
    /// Check post exist
    /// - Parameter postId: postID
    /// - Returns: true if exist
    func existPost(postId: Int) -> Bool {
        return (try? postStorage?.existsObject(forKey: postId)) ?? false
    }
    
    func remove(postId: Int) {
        try? postStorage?.removeObject(forKey: postId)
    }
    
    func clear() {
        try? postStorage?.removeAll()
        try? postStorage?.removeExpiredObjects()
    }
}
