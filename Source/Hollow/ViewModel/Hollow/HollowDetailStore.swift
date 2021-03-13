//
//  HollowDetailStore.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/21.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Combine
import SwiftUI
import Defaults
import Connectivity

class HollowDetailStore: ObservableObject, ImageCompressStore, AppModelEnvironment {
    // MARK: Post Variables
    var bindingPostWrapper: Binding<PostDataWrapper>
    @Published var postDataWrapper: PostDataWrapper
    @Published var isEditingAttention = false
    @Published var jumpToCommentId: Int?
    @Published var noSuchPost = false
    
    // MARK: Input Variables
    @Published var replyToIndex: Int = -2
    @Published var imageSizeInformation: String?
    var text: String = "" {
        didSet { if text == "" || oldValue == "" {
            self.objectWillChange.send()
        }}
    }
    @Published var image: UIImage?
    @Published var compressedImage: UIImage?

    // MARK: Shared Variables
    @Published var errorMessage: (title: String, message: String)?
    @Published var isLoading = false
    @Published var isSendingComment = false
    @Published var appModelState = AppModelState()
    
    private var cancellables = Set<AnyCancellable>()

    // MARK: -
    init(bindingPostWrapper: Binding<PostDataWrapper>, jumpToComment commentId: Int? = nil) {
        self.postDataWrapper = bindingPostWrapper.wrappedValue
        self.bindingPostWrapper = bindingPostWrapper
        self.jumpToCommentId = commentId
        
        requestDetail()
        
        // Subscribe the changes in post data in the detail store
        // and update the upstream data source. This will be the
        // source of truth when the detail view exists.
        $postDataWrapper
            .receive(on: DispatchQueue.main)
            .assign(to: \.bindingPostWrapper.wrappedValue, on: self)
            .store(in: &cancellables)

        // When reconnect to the internet, fetch again.
        ConnectivityPublisher.networkConnectedStatusPublisher
            .sink(receiveValue: { connected in
                if connected { self.requestDetail() }
            })
            .store(in: &cancellables)
    }
    
    func cancelAll() {
        cancellables.removeAll()
    }
    
    // MARK: - Load Post Detail
    func requestDetail() {
        guard let config = Defaults[.hollowConfig],
              let token = Defaults[.accessToken] else { return }
        let configuration = PostDetailRequestConfiguration(apiRoot: config.apiRootUrls, token: token, postId: postDataWrapper.post.postId, includeComments: true)
        let request = PostDetailRequest(configuration: configuration)
        
        withAnimation { self.isLoading = true }
        
        request.publisher
            .sinkOnMainThread(receiveCompletion: { completion in
                withAnimation { self.isLoading = false }
                switch completion {
                case .finished:
                    self.loadComponents()
                case .failure(let error):
                    switch error {
                    case .noSuchPost:
                        withAnimation { self.noSuchPost = true }
                    default: break
                    }
                    self.defaultErrorHandler(errorMessage: &self.errorMessage, error: error)
                }
            }, receiveValue: { postDataWrapper in
                withAnimation { self.isLoading = false }
                var finalWrapper = postDataWrapper
                // Preserve the asynchronous request result if there is any data,
                // which is not likly to be modified during the request.
                if let citedPost = self.postDataWrapper.citedPost {
                    finalWrapper.citedPost = citedPost
                }
                if let hollowImage = self.postDataWrapper.post.hollowImage {
                    finalWrapper.post.hollowImage = hollowImage
                }
                withAnimation { self.postDataWrapper = finalWrapper }
            })
            .store(in: &cancellables)
        
        loadComponents()
    }
    
    private func loadComponents() {
        loadPostImage()
        loadImages()
        loadCitedPost()
    }
    
    func loadPostImage() {
        if let imageURL = postDataWrapper.post.hollowImage?.imageURL,
           postDataWrapper.post.hollowImage?.image == nil {
            postDataWrapper.post.hollowImage?.loadingError = nil
            loadImage(
                for: imageURL,
                receiveValue: { image in withAnimation {
                    self.postDataWrapper.post.hollowImage?.image = image
                }},
                receiveError: { error in withAnimation {
                    self.postDataWrapper.post.hollowImage?.loadingError = error.description
                }}
            )
        }
    }
    
    private func loadImage(for imageURL: String, receiveValue: @escaping (UIImage) -> Void, receiveError: @escaping (FetchImageRequestError) -> Void) {
        guard let config = Defaults[.hollowConfig] else { return }
        let imageRequest = FetchImageRequest(configuration: .init(urlBase: config.imgBaseUrls, urlString: imageURL))

        imageRequest.publisher
            .retry(3)
            .sinkOnMainThread(
                receiveError: receiveError,
                receiveValue: receiveValue
            )
            .store(in: &cancellables)
    }
    
    private func loadCitedPost() {
        guard let citedPid = self.postDataWrapper.citedPostID,
              postDataWrapper.citedPost == nil ||
                postDataWrapper.citedPost?.loadingError != nil  else { return }
        guard let config = Defaults[.hollowConfig],
              let token = Defaults[.accessToken] else { return }
        let configuration = PostDetailRequestConfiguration(apiRoot: config.apiRootUrls, token: token, postId: citedPid, includeComments: false)
        let request = PostDetailRequest(configuration: configuration)
        
        request.publisher
            .map({ $0.post })
            .sinkOnMainThread(receiveError: { error in
                let description: String
                switch error {
                case .noSuchPost: description = error.description
                default: description = NSLocalizedString("CITED_POST_LOADING_ERROR", comment: "")
                }
                self.postDataWrapper.citedPost?.loadingError = description
            }, receiveValue: { postData in
                withAnimation { self.postDataWrapper.citedPost = postData }
            })
            .store(in: &cancellables)
    }
    
    
    // MARK: - Load Images in Comments
    private func loadImages() {
        let commentsWithNoImages: [CommentData] = postDataWrapper.post.comments
            .filter({ $0.image?.imageURL != nil && $0.image?.image == nil })
        guard let config = Defaults[.hollowConfig] else { return }
        let requests: [FetchImageRequest] = commentsWithNoImages.compactMap {
            let imageURL = $0.image!.imageURL
            let configuration = FetchImageRequestConfiguration(urlBase: config.imgBaseUrls, urlString: imageURL)
            return FetchImageRequest(configuration: configuration)
        }
        
        FetchImageRequest.publisher(for: requests, retries: 2)?
            .sinkOnMainThread(receiveValue: { index, output in
                let commentId = commentsWithNoImages[index].commentId
                switch output {
                case .failure(let error):
                    withAnimation {
                        self.sendImageLoadingError(error.description, to: commentId)
                    }
                case .success(let image):
                    self.assignImage(image, to: commentId)
                }
            })
            .store(in: &cancellables)
    }
    
    private func assignImage(_ image: UIImage, to commentId: Int) {
        guard let index = postDataWrapper.post.comments.firstIndex(where: { $0.commentId == commentId }) else { return }
        withAnimation {
            self.postDataWrapper.post.comments[index].image?.image = image
        }
    }
    
    private func sendImageLoadingError(_ error: String?, to commentId: Int) {
        guard let index = postDataWrapper.post.comments.firstIndex(where: { $0.commentId == commentId }) else { return }
        withAnimation {
            self.postDataWrapper.post.comments[index].image?.loadingError = error
        }
    }
    
    func reloadImage(_ hollowImage: HollowImage, commentId: Int) {
        if let index = postDataWrapper.post.comments.firstIndex(where: { $0.commentId == commentId }) {
            postDataWrapper.post.comments[index].image?.loadingError = nil
        }
        loadImage(
            for: hollowImage.imageURL,
            receiveValue: { self.assignImage($0, to: commentId) },
            receiveError: { self.sendImageLoadingError($0.description, to: commentId) }
        )
    }
    
    // MARK: - Vote And Star
    func vote(for option: String) {
        guard let config = Defaults[.hollowConfig],
              let token = Defaults[.accessToken] else { return }
        let request = SendVoteRequest(configuration: .init(apiRoot: config.apiRootUrls, token: token, option: option, postId: postDataWrapper.post.postId))
        
        request.publisher
            .retry(2)
            .sinkOnMainThread(receiveError: { error in
                self.defaultErrorHandler(errorMessage: &self.errorMessage, error: error)
            }, receiveValue: { result in withAnimation {
                self.postDataWrapper.post.vote = result
            }})
            .store(in: &cancellables)
    }
    
    func star(_ star: Bool) {
        guard let config = Defaults[.hollowConfig],
              let token = Defaults[.accessToken] else { return }
        let request = EditAttentionRequest(configuration: .init(apiRoot: config.apiRootUrls, token: token, postId: postDataWrapper.post.postId, switchToAttention: star))
        withAnimation { isEditingAttention = true }
        
        request.publisher
            .sinkOnMainThread(receiveError: { error in
                withAnimation { self.isEditingAttention = false }
                self.defaultErrorHandler(errorMessage: &self.errorMessage, error: error)
            }, receiveValue: { result in
                withAnimation {
                    self.isEditingAttention = false
                    self.postDataWrapper.post.attention = result.attention
                    self.postDataWrapper.post.likeNumber = result.likenum
                }
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Input Comments
    func sendComment() {
        guard let config = Defaults[.hollowConfig],
              let token = Defaults[.accessToken] else { return }
        let replyTo = replyToIndex == -1 ? -1 : postDataWrapper.post.comments[replyToIndex].commentId
        var text = self.text
        if replyToIndex >= 0 {
            text = "Re \(postDataWrapper.post.comments[replyToIndex].name): " + text
        }
        let configuration = SendCommentRequestConfiguration(apiRoot: config.apiRootUrls, token: token, text: text, imageData: compressedImage?.jpegData(compressionQuality: 0.7), postId: postDataWrapper.post.postId, replyCommentId: replyTo)
        
        let request = SendCommentRequest(configuration: configuration)
        
        withAnimation { isSendingComment = true }
        request.publisher
            .sinkOnMainThread(receiveError: { error in
                withAnimation { self.isSendingComment = false }
                self.defaultErrorHandler(errorMessage: &self.errorMessage, error: error)
            }, receiveValue: { result in
                withAnimation { self.isSendingComment = false }
                self.jumpToCommentId = result.commentId
                withAnimation { self.restoreInput() }
                self.requestDetail()
            })
            .store(in: &cancellables)
    }
    
    private func restoreInput() {
        self.text = ""
        self.replyToIndex = -2
        self.image = nil
        self.compressedImage = nil
        self.imageSizeInformation = nil
    }
    
    // MARK: - Report
    func report(commentId: Int? = nil, type: PostPermissionType, reason: String) {
        guard let config = Defaults[.hollowConfig],
              let token = Defaults[.accessToken] else { return }
        let postId = postDataWrapper.post.postId
        
        let configuration: ReportRequestGroupConfiguration
        
        if let commentId = commentId {
            configuration = .comment(.init(apiRoot: config.apiRootUrls, token: token, commentId: commentId, type: type, reason: reason))
        } else {
            configuration = .post(.init(apiRoot: config.apiRootUrls, token: token, postId: postId, type: type, reason: reason))
        }
        
        let request = ReportRequestGroup(configuration: configuration)
        
        withAnimation { isLoading = true }

        request.publisher
            .sinkOnMainThread(receiveCompletion: { completion in
                withAnimation { self.isLoading = true }

                switch completion {
                case .finished:
                    self.requestDetail()
                case .failure(let error):
                    // TODO: Handle user deletion
                    self.defaultErrorHandler(errorMessage: &self.errorMessage, error: error)
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}
