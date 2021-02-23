//
//  Timeline.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults
import Combine

class Timeline: ObservableObject, AppModelEnvironment {
    
    var page = 1
    var noMorePosts = false
    @Published var posts: [PostDataWrapper]
    @Published var isLoading = false
    @Published var loadFinished = false
    @Published var errorMessage: (title: String, message: String)?
    
    @Published var appModelState = AppModelState()

    var cancellables = Set<AnyCancellable>()
    
    init() {
        self.posts = []
        self.page = 1
        requestPosts(at: 1)
    }
    
    // MARK: - Load Posts
    private func requestPosts(at page: Int, handler: (() -> Void)? = nil) {
        guard !self.noMorePosts else { return }
        let config = Defaults[.hollowConfig]!
        let token = Defaults[.accessToken]!
        let request = PostListRequest(configuration: PostListRequestConfiguration(apiRoot: config.apiRootUrls, token: token, page: page, imageBaseURL: config.imgBaseUrls))
        withAnimation {
            isLoading = true
        }

        request.publisher
            .sinkOnMainThread(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        // Fetch images after loading all the posts.
                        self.fetchImages()
                        self.fetchCitedPosts()
                    case .failure(let error):
                        self.defaultErrorHandler(errorMessage: &self.errorMessage, error: error)
                    }
                }, receiveValue: { postWrappers in
                    withAnimation { self.isLoading = false }
                    if postWrappers.isEmpty {
                        self.noMorePosts = true
                        self.page = 1
                        return
                    }
                    withAnimation {
                        handler?()
                        self.integratePosts(postWrappers)
                    }
                }
            )
            .store(in: &cancellables)
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
    
    // MARK: - Load Images
    private func fetchImages() {
        let postsWithNoImages: [PostData] = posts.compactMap {
            guard let _ = $0.post.hollowImage?.imageURL,
                  $0.post.hollowImage?.image == nil else { return nil }
            return $0.post
        }
        let requests: [FetchImageRequest] = postsWithNoImages.compactMap {
            let imageURL = $0.hollowImage!.imageURL
            let configuration = FetchImageRequestConfiguration(urlBase: Defaults[.hollowConfig]!.imgBaseUrls, urlString: imageURL)
            return FetchImageRequest(configuration: configuration)
        }
        
        FetchImageRequest.publisher(for: requests, retries: 3)?
            .sinkOnMainThread(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished: break
                    case .failure(let error): print(error)
                    }
                },
                receiveValue: { index, image in
                    if let image = image {
                        self.assignImage(image, to: postsWithNoImages[index].postId)
                    } else {
                        // Fail to load the single image
                    }
                })
            .store(in: &cancellables)
    }
    
    private func assignImage(_ image: UIImage, to postId: Int) {
        // We use the postId rather than the index to
        // identify which post to assign to.
        guard let index = posts.firstIndex(where: { $0.post.postId == postId }) else { return }
        self.posts[index].post.hollowImage?.image = image
    }
    
    // MARK: - Load Cited Posts
    private func fetchCitedPosts() {
        let postsWrapperWithCitation = posts.compactMap { $0.citedPostID == nil ? nil : $0 }
        let citedPostId = postsWrapperWithCitation.compactMap { $0.citedPostID }
        
        let hollowConfig = Defaults[.hollowConfig]!
        let token = Defaults[.accessToken]!
        let requests: [PostDetailRequest] = citedPostId.map {
            let configuration = PostDetailRequestConfiguration(apiRoot: hollowConfig.apiRootUrls, token: token, postId: $0, includeComments: false)
            return PostDetailRequest(configuration: configuration)
        }
        PostDetailRequest.publisher(for: requests)?
            .sinkOnMainThread(receiveCompletion: { _ in
                // TODO
            }, receiveValue: { index, postData in
                if let postData = postData {
                    self.assignCitedPost(
                        postData.post,
                        to: postsWrapperWithCitation[index].post.postId
                    )
                } else {
                    // Error
                }
            })
            .store(in: &cancellables)
    }
    
    private func assignCitedPost(_ citedPost: PostData, to postId: Int) {
        guard let index = posts.firstIndex(where: { $0.post.postId == postId }) else { return }
        self.posts[index].citedPost = citedPost
    }
        
    // MARK: - Handle vote action
    func vote(postId: Int, for option: String) {
        // FIXME: Keep the version of vote in sync with detail view when the request is processing!
        let config = Defaults[.hollowConfig]!
        let token = Defaults[.accessToken]!
        let request = SendVoteRequest(configuration: .init(apiRoot: config.apiRootUrls, token: token, option: option, postId: postId))
        
        request.publisher
            .sinkOnMainThread(receiveError: { error in
                self.defaultErrorHandler(errorMessage: &self.errorMessage, error: error)
            }, receiveValue: { vote in
                if let index = self.posts.firstIndex(where: { $0.post.postId == postId }) {
                    withAnimation {
                        self.posts[index].post.vote = vote
                    }
                }
            })
            .store(in: &cancellables)
    }

}
