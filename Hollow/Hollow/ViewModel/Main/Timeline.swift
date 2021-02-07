//
//  Timeline.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

class Timeline: ObservableObject {
    @Published var posts: [PostDataWrapper]
    
    init() {
        // FOR DEBUG
        self.posts = Array.init(repeating: testPostDataWrapper2, count: 200)
//        self.posts = testPostWrappers + testPostWrappers
    }
    
    func vote(postId: Int, for option: String) {
        
    }
    
    func loadMorePosts() {
        self.posts += testPostWrappers.shuffled()
    }
    
    func refresh(_ isRefreshing: inout Bool) {
        // FOR TESTING
        self.posts = testPostWrappers.shuffled()
        isRefreshing = false
    }
}
