//
//  RequestError.swift
//  Hollow
//
//  Created by aliceinhollow on 9/2/2021.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

protocol RequestError: Error {
    var description: String { get }
}

enum DefaultRequestError: RequestError {
    case decodeFailed
    case tokenExpiredError
    case fileTooLarge
    case unknown
    case imageLoadingFail(postID: Int)
    case other(description: String)
    
    var description: String {
        switch self {
        case .tokenExpiredError: return "Token expired, please login again."
        case .decodeFailed: return "Fail to decode result from the response."
        case .unknown: return "Fail to initialize data. This is an internal error."
        case .fileTooLarge: return "The uploaded file is too large and is refused by the server."
        case .imageLoadingFail(let pid): return "Fail Loading Image in post \(pid)"
        case .other(let description): return description
        }
    }
    
    init(errorCode: Int, description: String?) {
        if errorCode == -100 {
            self = .tokenExpiredError
        } else {
            self = .other(description: description ?? "Unknown error!")
        }
    }
}
