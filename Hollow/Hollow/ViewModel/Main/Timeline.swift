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
//        self.posts = Array.init(repeating: testPostDataWrapper, count: 100) + Array.init(repeating: testPostDataWrapper3, count: 100)
        self.posts = testPostWrappers + testPostWrappers
    }
    
    func vote(postId: Int, for option: String) {
        
    }
}
