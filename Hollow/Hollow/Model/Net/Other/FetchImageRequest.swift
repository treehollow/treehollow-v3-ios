//
//  FetchImageRequest.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/22.
//  Copyright © 2021 treehollow. All rights reserved.
//

import UIKit
import Kingfisher

struct FetchImageRequestConfiguration {
    var urlBase: [String]
    var urlString: String
}

enum FetchImageRequestError: RequestError {
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


struct FetchImageRequest: Request {
    typealias Configuration = FetchImageRequestConfiguration
    typealias Result = UIImage
    typealias ResultData = Result
    typealias Error = FetchImageRequestError
    
    var configuration: FetchImageRequestConfiguration
    
    init(configuration: FetchImageRequestConfiguration) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (Result?, FetchImageRequestError?) -> Void) {
        let urlBase = configuration.urlBase[0]
        let urlString = urlBase + configuration.urlString
        guard let url = URL(string: urlString) else {
            completion(nil, .invalidURL)
            return
        }
        let resource = ImageResource(downloadURL: url, cacheKey: urlString)
        
        KingfisherManager.shared.retrieveImage(with: resource, options: [.memoryCacheExpiration(.never)]) { result in
            switch result {
            case .success(let value):
                completion(value.image, nil)
                completion(nil, .loadingCompleted)
            case .failure(let error):
                completion(nil, .failed(description: error.errorDescription ?? ""))
            }
        }

    }
}
