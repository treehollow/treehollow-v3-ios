//
//  MessageStore.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/3.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Combine
import Defaults
import SwiftUI

class MessageStore: ObservableObject, AppModelEnvironment {
    @Published var messages: [SystemMessage] = []
    @Published var errorMessage: (title: String, message: String)?
    @Published var isLoading = false
    
    var cancellables = Set<AnyCancellable>()
    
    init(lazyLoad: Bool = false) {
        if !lazyLoad {
            requestMessages()
        }
    }
    
    func requestMessages(completion: (() -> Void)? = nil) {
        guard let config = Defaults[.hollowConfig],
              let token = Defaults[.accessToken] else { return }
        let request = SystemMessageRequest(configuration: .init(token: token, apiRoot: config.apiRootUrls))
        
        withAnimation { isLoading = true }
        request.publisher
            .sinkOnMainThread(receiveError: {
                completion?()
                withAnimation { self.isLoading = false }
                self.defaultErrorHandler(errorMessage: &self.errorMessage, error: $0)
            }, receiveValue: { result in
                completion?()
                withAnimation { self.isLoading = false }

                self.messages = result
            })
            .store(in: &cancellables)
    }
}
