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


struct _FetchImageRequest: Request {
    struct Configuration {
        var urlBase: [String]
        var urlString: String
    }

    typealias Result = HImage
    typealias ResultData = Result
    
    enum Error: Swift.Error {
        case invalidURL
        case loadingCompleted
        case failed(description: String)

        var description: String {
            switch self {
            case .invalidURL: return NSLocalizedString("REQUEST_FETCH_IMAGE_ERROR_INVALID_URL", comment: "")
            case .loadingCompleted: return ""
            case .failed(let description): return description
            }
        }
    }

    var configuration: Configuration
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (ResultType<Result, Error>) -> Void) {
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
