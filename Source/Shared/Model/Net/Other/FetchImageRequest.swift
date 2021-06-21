//
//  FetchImageRequest.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/22.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Kingfisher
import HollowCore

typealias FetchImageRequest = DefaultGenericRequest<_FetchImageRequest>

struct FetchImageRequestConfiguration {
    var urlBase: [String]
    var urlString: String
}

enum FetchImageRequestError: Error {
    case invalidURL
    case loadingCompleted
    case failed(description: String)
    
    func loadingCompleted() -> Bool {
        switch self {
        case .loadingCompleted: return true
        default: return false
        }
    }
    var description: String {
        switch self {
        case .invalidURL: return NSLocalizedString("REQUEST_FETCH_IMAGE_ERROR_INVALID_URL", comment: "")
        case .loadingCompleted: return ""
        case .failed(let description): return description
        }
    }
}


struct _FetchImageRequest: Request {
    typealias Configuration = FetchImageRequestConfiguration
    typealias Result = HImage
    typealias ResultData = Result
    typealias Error = FetchImageRequestError
    
    var configuration: FetchImageRequestConfiguration
    
    init(configuration: FetchImageRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (ResultType<Result, FetchImageRequestError>) -> Void) {
        let urlBase = LineSwitchManager.lineSelection(for: configuration.urlBase, type: .imageBaseURL)
        let urlString = urlBase + configuration.urlString
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        let resource = ImageResource(downloadURL: url, cacheKey: urlString)
        
        DispatchQueue.global(qos: .background).async {
            KingfisherManager.shared.retrieveImage(with: resource, options: [.memoryCacheExpiration(.never)]) { result in
                switch result {
                case .success(let value):
                    completion(.success(value.image))
                case .failure(let error):
                    completion(.failure(.failed(description: error.errorDescription ?? "")))
                }
            }
        }

    }
}
