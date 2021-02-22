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
    var noMorePosts = false
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
        guard !self.noMorePosts else { return }
        let config = Defaults[.hollowConfig]!
        let token = Defaults[.accessToken]!
        let request = PostListRequest(configuration: PostListRequestConfiguration(apiRoot: config.apiRootUrls, token: token, page: page, imageBaseURL: config.imgBaseUrls))
        withAnimation {
            isLoading = true
        }
        request.performRequest(completion: { postWrappers, error in
            withAnimation {
                self.isLoading = false
            }
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
                    self.noMorePosts = true
                    self.page = 1
                    return
                }
                withAnimation {
                    self.integratePosts(postWrappers)
                }
            }
        })
    }
    
    private func integratePosts(_ newPosts: [PostDataWrapper]) {
        var posts = self.posts
        for newPost in newPosts {
            var found = false
            for index in posts.indices {
                if newPost.id == posts[index].id {
                    posts[index] = newPost
                    found = true
                }
            }
            if !found {
                posts.append(newPost)
            }
        }
        posts.sort(by: { $0.post.postId > $1.post.postId })
        self.posts = posts
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
        noMorePosts = false
        requestPosts(at: 1, handler: {
            self.posts = []
        })
        finshHandler()
    }
}
