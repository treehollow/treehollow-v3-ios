//
//  Timeline.swift
//  Hollow
//
//  Created by 梁业升 on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

class Timeline: ObservableObject {
    @Published var posts: [PostData]
    
    init() {
        // FOR DEBUG
//        self.posts = Array.init(repeating: testPostData, count: 10)
        self.posts = testPosts + testPosts
    }
    
    func vote(postId: Int, for option: String) {
        
    }
}
