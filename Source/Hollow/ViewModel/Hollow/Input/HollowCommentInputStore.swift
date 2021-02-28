//
//  HollowCommentInputStore.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/17.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import Defaults

class HollowCommentInputStore: ObservableObject, AppModelEnvironment, ImageCompressStore {
    var presented: Binding<Bool>
    var postId: Int
    var replyTo: Int
    var replyToName: String
    var onFinishSending: () -> Void
    @Published var appModelState = AppModelState()
    @Published var errorMessage: (title: String, message: String)?
    @Published var imageSizeInformation: String?
    @Published var isLoading = false
    @Published var text: String = ""
    @Published var image: UIImage?
    @Published var compressedImage: UIImage?
    
    var cancellables =  Set<AnyCancellable>()
    
    init(presented: Binding<Bool>, postId: Int, replyTo: Int, name: String, onFinishSending: @escaping () -> Void) {
        self.presented = presented
        self.postId = postId
        self.replyTo = replyTo
        self.replyToName = name
        self.onFinishSending = onFinishSending
    }
    
    func sendComment() {
        let config = Defaults[.hollowConfig]!
        let token = Defaults[.accessToken]!
        let configuration = SendCommentRequestConfiguration(apiRoot: config.apiRootUrls, token: token, text: text, imageData: compressedImage?.jpegData(compressionQuality: 0.7), postId: postId, replyCommentId: replyTo)
        
        let request = SendCommentRequest(configuration: configuration)
        
        withAnimation { isLoading = true }
        request.publisher
            .sinkOnMainThread(receiveError: { error in
                withAnimation { self.isLoading = false }
                self.defaultErrorHandler(errorMessage: &self.errorMessage, error: error)
            }, receiveValue: { _ in
                withAnimation {
                    self.isLoading = false
                    self.presented.wrappedValue = false
                }
                self.onFinishSending()
            })
            .store(in: &cancellables)
    }
}

