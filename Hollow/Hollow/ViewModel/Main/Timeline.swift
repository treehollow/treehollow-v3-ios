//
//  Timeline.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

class Timeline: ObservableObject, AppModelEnvironment {
    
    var page = 1
    @Published var posts: [PostDataWrapper]
    @Published var isLoading = false
    @Published var loadFinished = false
    @Published var errorMessage: (title: String, message: String)?
    
    @Published var appModelState = AppModelState()

    
    init() {
        self.posts = []
        self.page = 1
        requestPosts(at: 1)
    }
    
    private func requestPosts(at page: Int, handler: (() -> Void)? = nil) {
        let config = Defaults[.hollowConfig]!
        let token = Defaults[.accessToken]!
        let request = PostListRequest(configuration: PostListRequestConfiguration(apiRoot: config.apiRootUrls, token: token, page: page, imageBaseURL: config.imgBaseUrls))
        isLoading = true
        request.performRequest(completion: { postWrappers, error in
            self.isLoading = false
            handler?()
            if let error = error {
                if self.handleTokenExpireError(error) { return }
                
                // TODO: Handle errors
                switch error {
                case .imageLoadingFail:
                    break
                default:
                    self.errorMessage = (title: String.errorLocalized.capitalized, message: error.description)
                }
                
                return
            }
            
            if let postWrappers = postWrappers {
                if postWrappers.isEmpty {
                    return
                }
                withAnimation {
                    self.integratePosts(postWrappers)
                }
            }
        })
    }
    
    private func integratePosts(_ newPosts: [PostDataWrapper]) {
        for newPost in newPosts {
            var found = false
            for index in self.posts.indices {
                if newPost.id == self.posts[index].id {
                    self.posts[index] = newPost
                    found = true
                }
            }
            if !found {
                self.posts.append(newPost)
            }
        }
        self.posts.sort(by: { $0.id > $1.id })
    }
    
    func vote(postId: Int, for option: String) {
        
    }
    
    func loadMorePosts() {
        guard !isLoading else { return }
        self.page += 1
        requestPosts(at: page)
    }
    
    func refresh(finshHandler: @escaping () -> Void) {
        page = 1
        requestPosts(at: 1, handler: {
            self.posts = []
        })
        finshHandler()
    }
}
