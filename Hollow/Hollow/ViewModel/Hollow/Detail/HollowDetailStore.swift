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

class HollowDetailStore: ObservableObject {
    @Published var postDataWrapper: Binding<PostDataWrapper>
    @Published var errorMessage: (title: String, message: String)?
    @Published var isLoading = false

    init(postDataWrapper: Binding<PostDataWrapper>) {
        self.postDataWrapper = postDataWrapper
        requestDetail()
    }
    
    func requestDetail() {
        let config = Defaults[.hollowConfig]!
        let token = Defaults[.accessToken]!
        let request = PostDetailRequest(configuration: PostDetailRequestConfiguration(apiRoot: config.apiRootUrls, imageBaseURL: config.imgBaseUrls, token: token, postId: postDataWrapper.wrappedValue.post.postId, includeComments: true, includeCitedPost: true, includeImage: true))
        
        request.performRequest(completion: { postDataWrapper, error in
            if let error = error {
                self.errorMessage = (title: String.errorLocalized.capitalized, message: error.description)
                return
                // Handle error
            }
            
            if let postWrapper = postDataWrapper {
                self.postDataWrapper.wrappedValue = postWrapper
            }
        })
    }
}
