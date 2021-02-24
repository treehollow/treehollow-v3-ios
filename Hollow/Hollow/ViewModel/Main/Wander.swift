//
//  Wander.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Combine
import Defaults
import SwiftUI

class Wander: ObservableObject, AppModelEnvironment {
    var page = 1
    var noMorePosts = false
    
    @Published var posts: [PostData]
    @Published var isLoading = false
    @Published var errorMessage: (title: String, message: String)?
    
    @Published var appModelState = AppModelState()
    
    var cancellables = Set<AnyCancellable>()

    init() {
        self.posts = []
        requestPosts(at: 1)
    }
    
    func requestPosts(at page: Int, completion: (() -> Void)? = nil) {
        guard !self.noMorePosts else { return }
        let config = Defaults[.hollowConfig]!
        let token = Defaults[.accessToken]!
        let request = RandomListRequest(configuration: .init(apiRoot: config.apiRootUrls, token: token, page: page))
        withAnimation {
            isLoading = true
        }
        
        request.publisher
            .map { $0.map { $0.post } }
            .sinkOnMainThread(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.fetchImages()
                case .failure(let error):
                    self.defaultErrorHandler(errorMessage: &self.errorMessage, error: error)
                }
            }, receiveValue: { result in
                withAnimation { self.isLoading = false }
                if result.isEmpty {
                    self.noMorePosts = true
                    self.page = 1
                    return
                }
                completion?()
                withAnimation {
                    self.integratePosts(result)
                }
            })
            .store(in: &cancellables)
    }
    
    private func integratePosts(_ newPosts: [PostData]) {
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
        self.posts = posts
    }
    
    func loadMorePosts(clearPosts: Bool) {
        guard !isLoading else { return }
        self.page += 1
        
        requestPosts(at: page, completion: {
            if clearPosts {
                withAnimation { self.posts.removeAll() }
            }
        })
    }

    func refresh(finshHandler: (() -> Void)? = nil) {
        page = 1
        withAnimation {
            noMorePosts = false
        }
        let handler = {
            finshHandler?()
            self.posts.removeAll()
        }
        requestPosts(at: 1, completion: handler)
    }

    private func fetchImages() {
        let postsWithNoImages: [PostData] = posts.filter {
            $0.hollowImage?.imageURL != nil && $0.hollowImage?.image == nil
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
        guard let index = posts.firstIndex(where: { $0.postId == postId }) else { return }
        posts[index].hollowImage?.image = image
    }
}
