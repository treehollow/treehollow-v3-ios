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

class HollowDetailStore: ObservableObject, AppModelEnvironment {
    var bindingPostWrapper: Binding<PostDataWrapper>
    @Published var postDataWrapper: PostDataWrapper
    @Published var errorMessage: (title: String, message: String)?
    @Published var isLoading = false
    
    @Published var appModelState = AppModelState()
    
    private var cancellables = Set<AnyCancellable>()

    init(bindingPostWrapper: Binding<PostDataWrapper>) {
        self.postDataWrapper = bindingPostWrapper.wrappedValue
        self.bindingPostWrapper = bindingPostWrapper
        requestDetail()
        
        // Subscribe the changes in post data in the detail store
        // and update the upstream data source. This will be the
        // source of truth when the detail view exists.
        $postDataWrapper
            .receive(on: DispatchQueue.main)
            .assign(to: \.wrappedValue, on: self.bindingPostWrapper)
            .store(in: &cancellables)
    }
    
    // MARK: - Load Post Detail
    private func requestDetail() {
        let config = Defaults[.hollowConfig]!
        let token = Defaults[.accessToken]!
        let configuration = PostDetailRequestConfiguration(apiRoot: config.apiRootUrls, token: token, postId: postDataWrapper.post.postId, includeComments: true)
        let request = PostDetailRequest(configuration: configuration)
        
        withAnimation { self.isLoading = true }
        
        request.publisher
            .sinkOnMainThread(receiveCompletion: { completion in
                withAnimation { self.isLoading = false }
                switch completion {
                case .finished:
                    self.loadImages()
                    self.loadCitedPost()
                case .failure(let error):
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
        
        loadPostImage()
        loadImages()
        loadCitedPost()
    }
    
    private func loadPostImage() {
        if let imageURL = postDataWrapper.post.hollowImage?.imageURL,
           postDataWrapper.post.hollowImage?.image == nil {
            let config = Defaults[.hollowConfig]!
            let imageRequest = FetchImageRequest(configuration: .init(urlBase: config.imgBaseUrls, urlString: imageURL))

            imageRequest.publisher
                .retry(3)
                .sinkOnMainThread(receiveError: { error in
                    // TODO: Handle error
                }, receiveValue: { image in
                    withAnimation {
                        self.postDataWrapper.post.hollowImage?.image = image
                    }
                })
                .store(in: &cancellables)
        }
    }
    
    private func loadCitedPost() {
        guard let citedPid = self.postDataWrapper.citedPostID,
              postDataWrapper.citedPost == nil else { return }
        let config = Defaults[.hollowConfig]!
        let token = Defaults[.accessToken]!
        let configuration = PostDetailRequestConfiguration(apiRoot: config.apiRootUrls, token: token, postId: citedPid, includeComments: false)
        let request = PostDetailRequest(configuration: configuration)
        
        request.publisher
            .map({ $0.post })
            .sinkOnMainThread(receiveError: { error in
                
            }, receiveValue: { postData in
                withAnimation { self.postDataWrapper.citedPost = postData }
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Load Images in Comments
    private func loadImages() {
        let commentsWithNoImages: [CommentData] = postDataWrapper.post.comments
            .filter({ $0.image?.imageURL != nil && $0.image?.image == nil })
        let requests: [FetchImageRequest] = commentsWithNoImages.compactMap {
            let imageURL = $0.image!.imageURL
            let configuration = FetchImageRequestConfiguration(urlBase: Defaults[.hollowConfig]!.imgBaseUrls, urlString: imageURL)
            return FetchImageRequest(configuration: configuration)
        }
        
        FetchImageRequest.publisher(for: requests, retries: 3)?
            .sinkOnMainThread(receiveValue: { index, output in
                switch output {
                case .failure:
                    // TORO: Handle error
                    break
                case .success(let image):
                    self.assignImage(image, to: commentsWithNoImages[index].commentId)
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
    
    // MARK: - Vote
    func vote(for option: String) {
        let config = Defaults[.hollowConfig]!
        let token = Defaults[.accessToken]!
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
}
