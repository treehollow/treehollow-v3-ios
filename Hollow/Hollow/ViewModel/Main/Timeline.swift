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
        #if DEBUG
//        self.posts = Array.init(repeating: testPostDataWrapperNoExtraComponents, count: 200)
        self.posts = []
        for i in 0...200 {
            self.posts.append(testPostWrapper(forPostId: 189201 + i))
        }
        #else
        self.posts = []
        #endif
    }
    
    func vote(postId: Int, for option: String) {
        
    }
    
    func loadMorePosts() {
        #if DEBUG
//        self.posts += testPostWrappers.shuffled()
        #endif
    }
    
    func refresh(finshHandler: @escaping () -> Void) {
        // FOR TESTING
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            #if DEBUG
            withAnimation {
                self.posts = self.posts.shuffled()
            }
            #endif
            finshHandler()
//        }
    }
}
