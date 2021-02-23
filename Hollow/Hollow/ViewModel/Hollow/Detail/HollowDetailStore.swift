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
    
    var publishPostDataWrapperPublisher: AnyCancellable?
    var getPostDataCancellable: AnyCancellable?

    init(bindingPostWrapper: Binding<PostDataWrapper>) {
        self.postDataWrapper = bindingPostWrapper.wrappedValue
        self.bindingPostWrapper = bindingPostWrapper
        requestDetail()
        
        // Subscribe the changes in post data in the detail store
        // and update the upstream data source. This will be the
        // source of truth when the detail view exists.
        publishPostDataWrapperPublisher =
            $postDataWrapper.sink(receiveValue: { postDataWrapper in
                self.bindingPostWrapper.wrappedValue = postDataWrapper
            })
    }
    
    func requestDetail() {
        let config = Defaults[.hollowConfig]!
        let token = Defaults[.accessToken]!
        let configuration = PostDetailRequestConfiguration(apiRoot: config.apiRootUrls, imageBaseURL: config.imgBaseUrls, token: token, postId: postDataWrapper.post.postId, includeComments: true, includeCitedPost: true, includeImage: true)
        let request = PostDetailRequest(configuration: configuration)
        
        getPostDataCancellable = request.publisher
            .sinkOnMainThread(receiveError: { error in
                self.defaultErrorHandler(errorMessage: &self.errorMessage, error: error)
            }, receiveValue: { postDataWrapper in
                var finalWrapper = postDataWrapper
                if let citedPost = self.postDataWrapper.citedPost {
                    finalWrapper.citedPost = citedPost
                }
                if let hollowImage = self.postDataWrapper.post.hollowImage {
                    finalWrapper.post.hollowImage = hollowImage
                }
                withAnimation { self.postDataWrapper = finalWrapper }
            })
    }
    
    func vote(for option: String) {
        let config = Defaults[.hollowConfig]!
        let token = Defaults[.accessToken]!
        let request = SendVoteRequest(configuration: .init(apiRoot: config.apiRootUrls, token: token, option: option, postId: postDataWrapper.post.postId))
        
        request.performRequest(completion: { result, error in
            if let _ = error {
                // TODO: Handle error
            }
            
            // FIXME
            self.requestDetail()
        })
    }
}
