//
//  PostListRequestStore.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults
import Combine

/// Shared view model for views that request `PostList`, `Search`, `AttentionList`
/// and `AttentionListSearch`.
class PostListRequestStore: ObservableObject, AppModelEnvironment {
    
    // MARK: - Shared Variables
    let type: PostListRequestGroupType
    var page = 1
    var noMorePosts = false
    var options: Options = []
    @Published var posts: [PostDataWrapper]
    @Published var isLoading = false
    @Published var isEditingAttention = false
    @Published var errorMessage: (title: String, message: String)?
    @Published var appModelState = AppModelState()

    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Search Specific Variables
    
    @Published var searchString: String = ""
    @Published var excludeComments = false
    
    init(type: PostListRequestGroupType, options: Options = []) {
        self.type = type
        self.posts = []
        self.options = options
        if type == .searchTrending { searchString = Defaults[.hollowConfig]!.searchTrending }
        switch type {
        case .postList, .attentionList, .wander, .searchTrending: requestPosts(at: 1)
        default: break
        }
    }
    
    // MARK: - Load Posts
    func requestPosts(at page: Int, completion: (() -> Void)? = nil) {
        guard !self.noMorePosts else { return }
        let config = Defaults[.hollowConfig]!
        let token = Defaults[.accessToken]!
        let configuration: PostListRequestGroupConfiguration
        switch type {
        case .attentionList:
            configuration = .attentionList(.init(apiRoot: config.apiRootUrls, token: token, page: page))
        case .attentionListSearch:
            configuration = .attentionListSearch(.init(apiRoot: config.apiRootUrls, imageBaseURL: config.imgBaseUrls, token: token, keywords: searchString, page: page))
        case .postList:
            configuration = .postList(.init(apiRoot: config.apiRootUrls, token: token, page: page))
        case .search, .searchTrending:
            // FIXME: Other attributes
            configuration = .search(.init(apiRoot: config.apiRootUrls, token: token, keywords: searchString, page: page, beforeTimestamp: nil, includeComment: !excludeComments))
        case .wander:
            configuration = .wander(.init(apiRoot: config.apiRootUrls, token: token, page: page))
        }
        let request = PostListRequestGroup(configuration: configuration)
        withAnimation {
            isLoading = true
        }

        request.publisher
            .print()
            .sinkOnMainThread(
                receiveCompletion: { completion in
                    withAnimation { self.isLoading = false }
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
                    completion?()
                    withAnimation {
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
        withAnimation {
            noMorePosts = false
        }
        let completion = {
            finshHandler()
            self.posts.removeAll()
        }
        requestPosts(at: 1, completion: completion)
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
        if !options.contains(.unordered) {
            posts.sort(by: { $0.post.postId > $1.post.postId })
        }
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
            .sinkOnMainThread(receiveValue: { index, output in
                switch output {
                case .failure: break // handle error
                case .success(let image):
                    self.assignImage(image, to: postsWithNoImages[index].postId)
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
        let postsWrapperWithCitation = posts.filter { $0.citedPostID != nil }
        let citedPostId = postsWrapperWithCitation.compactMap { $0.citedPostID }
        
        let hollowConfig = Defaults[.hollowConfig]!
        let token = Defaults[.accessToken]!
        let requests: [PostDetailRequest] = citedPostId.map {
            let configuration = PostDetailRequestConfiguration(apiRoot: hollowConfig.apiRootUrls, token: token, postId: $0, includeComments: false)
            return PostDetailRequest(configuration: configuration)
        }
        PostDetailRequest.publisher(for: requests)?
            .sinkOnMainThread(receiveValue: { index, output in
                switch output {
                case .failure(let error):
                    switch error {
                    case .noSuchPost:
                        self.assignCitedPostError(
                            error.description,
                            to: postsWrapperWithCitation[index].post.postId
                        )
                    default: break
                    }
                case .success(let postData):
                    self.assignCitedPost(
                        postData.post,
                        to: postsWrapperWithCitation[index].post.postId
                    )
                }
            })
            .store(in: &cancellables)
    }
    
    private func assignCitedPost(_ citedPost: PostData, to postId: Int) {
        guard let index = posts.firstIndex(where: { $0.post.postId == postId }) else { return }
        self.posts[index].citedPost = citedPost
    }
    
    private func assignCitedPostError(_ error: String, to postId: Int) {
        guard let index = posts.firstIndex(where: { $0.post.postId == postId }) else { return }
        var post = PostDataWrapper.templatePost(for: postId).post
        post.loadingError = error
        self.posts[index].citedPost = post
    }
        
    // MARK: - Handle vote and star action
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
    
    func star(_ star: Bool, for postId: Int) {
        guard !isEditingAttention else { return }
        let config = Defaults[.hollowConfig]!
        let token = Defaults[.accessToken]!
        let request = EditAttentionRequest(configuration: .init(apiRoot: config.apiRootUrls, token: token, postId: postId, switchToAttention: star))
        withAnimation { isEditingAttention = true }
        
        request.publisher
            .sinkOnMainThread(receiveError: { error in
                withAnimation { self.isEditingAttention = false }
                self.defaultErrorHandler(errorMessage: &self.errorMessage, error: error)
            }, receiveValue: { result in
                withAnimation {
                    self.isEditingAttention = false
                    self.assignAttentionResult(result.attention, starNumber: result.likenum, to: postId)
                }
            })
            .store(in: &cancellables)
    }

    func assignAttentionResult(_ attention: Bool, starNumber: Int, to postId: Int) {
        guard let index = posts.firstIndex(where: { $0.post.id == postId }) else { return }
        withAnimation {
            posts[index].post.attention = attention
            posts[index].post.likeNumber = starNumber
        }
    }

}

extension PostListRequestStore {
    struct Options: OptionSet {
        let rawValue: Int
        
        static let ignoreCitedPost = Options(rawValue: 1 << 0)
        static let ignoreComments = Options(rawValue: 1 << 1)
        static let unordered = Options(rawValue: 1 << 2)
    }
}