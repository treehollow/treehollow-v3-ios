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
    
    var postDataWrapperPublisher: AnyCancellable?

    init(bindingPostWrapper: Binding<PostDataWrapper>) {
        self.postDataWrapper = bindingPostWrapper.wrappedValue
        self.bindingPostWrapper = bindingPostWrapper
        
        // Subscribe the changes in post data in the detail store
        // and update the upstream data source. This will be the
        // source of truth when the detail view exists.
        postDataWrapperPublisher =
            $postDataWrapper.sink(receiveValue: { postDataWrapper in
                self.bindingPostWrapper.wrappedValue = postDataWrapper
            })
    }
    
    func requestDetail() {
        let config = Defaults[.hollowConfig]!
        let token = Defaults[.accessToken]!
        let request = PostDetailRequest(configuration: PostDetailRequestConfiguration(apiRoot: config.apiRootUrls, imageBaseURL: config.imgBaseUrls, token: token, postId: postDataWrapper.post.postId, includeComments: postDataWrapper.citedPost == nil, includeCitedPost: false, includeImage: true))
        
        request.performRequest(completion: { postDataWrapper, error in
            if let error = error {
                if self.handleTokenExpireError(error) { return }
                self.errorMessage = (title: String.errorLocalized.capitalized, message: error.description)
                return
                // Handle error
            }
            
            if var postWrapper = postDataWrapper {
                postWrapper.citedPost = self.postDataWrapper.citedPost
                withAnimation { self.postDataWrapper = postWrapper }
            }
        })
    }
}
