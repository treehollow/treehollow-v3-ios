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
import HollowCore

/// Shared view model for views that request `PostList`, `Search`, `AttentionList`
/// and `AttentionListSearch`.
class PostListRequestStore: ObservableObject, HollowErrorHandler {
    
    // MARK: - Shared Variables
    let type: PostListRequestGroup.R.RequestType
    var page = 1
    var noMorePosts = false
    var options: Options = []
    @Published var posts: [PostDataWrapper]
    @Published var isLoading = false
    @Published var isEditingAttention = false
    @Published var errorMessage: (title: String, message: String)?
    @Published var allowLoadMorePosts = false

    var cancellables = Set<AnyCancellable>()
    
    // MARK: Search Specific Variables
    @Published var searchString: String = ""
    @Published var excludeComments = false
    @Published var startDate: Date?
    @Published var endDate: Date?
    
    // MARK: Widget
    @Published var invalidToken = false

    // MARK: -
    init(type: PostListRequestGroup.R.RequestType, options: Options = []) {
        self.type = type
        self.posts = []
        self.options = options
        if type == .searchTrending { searchString = Defaults[.hollowConfig]?.searchTrending ?? "" }
        if !options.contains(.lazyLoad) {
            switch type {
            case .postList, .attentionList, .wander, .searchTrending: requestPosts(at: 1)
            default: break
            }
        }
    }
    
    // MARK: - Load Posts
    func requestPosts(at page: Int, completion: (() -> Void)? = nil) {
        guard !self.noMorePosts else { return }
        guard let config = Defaults[.hollowConfig],
              let token = Defaults[.accessToken] else {
            withAnimation { invalidToken = true }
            return
        }
        let configuration: PostListRequestGroup.Configuration
        switch type {
        case .attentionList:
            configuration = .attentionList(.init(apiRoot: config.apiRootUrls.first!, token: token, page: page))
        case .attentionListSearch:
            configuration = .attentionListSearch(.init(apiRoot: config.apiRootUrls.first!, token: token, keywords: searchString, page: page))
        case .postList:
            configuration = .postList(.init(apiRoot: config.apiRootUrls.first!, token: token, page: page))
        case .search, .searchTrending:
            let startTimestamp = startDate?.startOfDay.timeIntervalSince1970.int
            var endTimestamp: Int? = nil
            if let offsetTimestamp = endDate?.endOfDay.timeIntervalSince1970.int {
                // Offset back. See `DateExtensions.swift`
                endTimestamp = offsetTimestamp + 60
            }
            configuration = .search(.init(apiRoot: config.apiRootUrls.first!, token: token, keywords: searchString, page: page, afterTimestamp: startTimestamp, beforeTimestamp: endTimestamp, includeComment: !excludeComments))
        case .wander:
            configuration = .wander(.init(apiRoot: config.apiRootUrls.first!, token: token, page: page))
        }
        let request = PostListRequestGroup(configuration: configuration)
        withAnimation {
            isLoading = true
        }

        request.publisher
            .sinkOnMainThread(
                receiveCompletion: { _completion in
                    withAnimation { self.isLoading = false }
                    completion?()
                    switch _completion {
                    case .finished: break
                    // We handle the completion on receiving value. The only output
                    // marks the completion, but is delivered before the completion,
                    // so if we want to deal with the result asynchronously, we should
                    // fetch other components when the asynchronous work is done.
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
        guard !isLoading && allowLoadMorePosts else { return }
        allowLoadMorePosts = false
        self.page += 1
        requestPosts(at: page, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.allowLoadMorePosts = true
            }
        })
    }
    
    func refresh(finshHandler: @escaping () -> Void) {
        page = 1
        withAnimation {
            noMorePosts = false
            allowLoadMorePosts = false
        }
        let completion = {
            finshHandler()
            self.posts.removeAll()
        }
        requestPosts(at: 1, completion: completion)
    }
    
    private func integratePosts(_ newPosts: [PostDataWrapper]) {
        DispatchQueue.global(qos: .background).async {
            var posts = self.posts
            for newPost in newPosts {
                var found = false
                for index in posts.indices {
                    if newPost.id == posts[index].id {
                        let citedPost = posts[index].citedPost
                        posts[index] = newPost
                        posts[index].citedPost = citedPost
                        found = true
                    }
                }
                if !found {
                    posts.append(newPost)
                }
            }
            if !self.options.contains(.unordered) {
                posts.sort(by: { $0.post.postId > $1.post.postId })
            }
            DispatchQueue.main.async {
                self.posts = posts
                // Fetch other components after we assign the posts.
                self.fetchImages()
                self.fetchCitedPosts()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.allowLoadMorePosts = true
                }
            }
        }
    }
    
    // MARK: - Load Images
    func fetchImages() {
        let postsWithNoImages: [PostData] = posts.compactMap {
            guard let _ = $0.post.hollowImage?.imageURL,
                  $0.post.hollowImage?.image == nil else { return nil }
            return $0.post
        }
        let requests: [FetchImageRequest] = postsWithNoImages.compactMap {
            let imageURL = $0.hollowImage!.imageURL
            let configuration = FetchImageRequest.Configuration(urlBase: Defaults[.hollowConfig]?.imgBaseUrls ?? [], urlString: imageURL)
            return FetchImageRequest(configuration: configuration)
        }
        
        FetchImageRequest.publisher(for: requests, retries: 2)?
            .sinkOnMainThread(receiveValue: { index, output in
                let postId = postsWithNoImages[index].postId
                switch output {
                case .failure(let error):
                    self.sendImageLoadingError(error.description, to: postId)
                case .success(let image):
                    self.assignImage(image, to: postId)
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
    
    private func sendImageLoadingError(_ error: String?, to postId: Int) {
        guard let index = posts.firstIndex(where: { $0 .post.postId == postId }) else { return }
        withAnimation {
            self.posts[index].post.hollowImage?.loadingError = error
        }
    }
    
    // MARK: - Load Cited Posts
    private func fetchCitedPosts() {
        let postsWrapperWithCitation = posts.filter { $0.citedPostID != nil && $0.citedPost == nil }
        let citedPostId = postsWrapperWithCitation.compactMap { $0.citedPostID }
        
        guard let config = Defaults[.hollowConfig],
              let token = Defaults[.accessToken] else { return }
        let requests: [PostDetailRequest] = citedPostId.map {
            let configuration = PostDetailRequest.Configuration(apiRoot: config.apiRootUrls.first!, token: token, postId: $0, includeComments: false)
            return PostDetailRequest(configuration: configuration)
        }
        PostDetailRequest.publisher(for: requests)?
            .sinkOnMainThread(receiveValue: { index, output in
                switch output {
                case .failure(let error):
                    let description: String
                    switch error {
                    case .noSuchPost: description = error.localizedDescription
                    default: description = NSLocalizedString("CITED_POST_LOADING_ERROR", comment: "")
                    }
                    self.assignCitedPostError(
                        description,
                        to: postsWrapperWithCitation[index].post.postId
                    )
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
        guard let config = Defaults[.hollowConfig],
              let token = Defaults[.accessToken] else { return }
        let request = SendVoteRequest(configuration: .init(apiRoot: config.apiRootUrls.first!, token: token, option: option, postId: postId))
        
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
        guard let config = Defaults[.hollowConfig],
              let token = Defaults[.accessToken] else { return }
        let request = EditAttentionRequest(configuration: .init(apiRoot: config.apiRootUrls.first!, token: token, postId: postId, switchToAttention: star))
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
        guard let index = posts.firstIndex(where: { $0.post.postId == postId }) else { return }
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
        static let lazyLoad = Options(rawValue: 1 << 3)
    }
}
