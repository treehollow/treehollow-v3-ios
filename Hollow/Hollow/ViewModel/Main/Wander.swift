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
        #if DEBUG
//        self.posts = Array.init(repeating: testPostData, count: 200)
        self.posts = []
        for i in 0...50 {
            self.posts.append(testPostWrapper(forPostId: 189201 + i).post)
        }
        #else
        self.posts = []
        #endif
    }
}
