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
import Defaults
import UIKit

typealias FetchImageRequest = DefaultGenericRequest<_FetchImageRequest>


struct _FetchImageRequest: Request {
    struct Configuration {
        var urlBase: [String]
        var urlString: String
    }

    typealias Result = UIImage
    typealias ResultData = Result
    
    enum Error: Swift.Error {
        case invalidURL
        case failed(description: String)

        var description: String {
            switch self {
            case .invalidURL: return NSLocalizedString("REQUEST_FETCH_IMAGE_ERROR_INVALID_URL", comment: "")
            case .failed(let description): return description
            }
        }
    }

    var configuration: Configuration
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (ResultType<Result, Error>) -> Void) {
        guard let urlBase = Defaults[.hollowConfig]?.imgBaseUrls.first else { return }
        let urlString = urlBase + configuration.urlString
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let resource = ImageResource(downloadURL: url, cacheKey: urlString)
        
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
