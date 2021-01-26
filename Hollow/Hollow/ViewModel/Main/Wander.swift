//
//  Wander.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Combine

class Wander: ObservableObject {
    @Published var posts: [PostData]
    init() {
        // FOR DEBUG
//        self.posts = Array.init(repeating: testPostData, count: 10)
        self.posts = testPosts + testPosts + testPosts
    }
}
