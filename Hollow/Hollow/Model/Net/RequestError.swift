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
    func loadingCompleted() -> Bool
}

enum DefaultRequestError: RequestError {
    case decodeFailed
    case tokenExpiredError
    case fileTooLarge
    case unknown
    case imageLoadingFail(postID: Int)
    case commentImageLoadingFail(postID: Int, commentID: Int)
    case noSuchPost
    /// Indicating that current request has finished successfully.
    case loadingCompleted
    case other(description: String)
    
    var description: String {
        switch self {
        case .tokenExpiredError: return "Token expired, please login again."
        case .decodeFailed: return "Fail to decode result from the response."
        case .unknown: return "Fail to initialize data. This is an internal error."
        case .fileTooLarge: return "The uploaded file is too large and is refused by the server."
        case .imageLoadingFail(let postID): return "Fail to load image for post" + " #\(postID)."
        case .commentImageLoadingFail(let postID, let commentID): return "Fail to load image for comment #\(commentID) in post #\(postID)."
        case .noSuchPost: return "The post does not exist."
        case .loadingCompleted: return ""
        case .other(let description): return description
        }
    }
    
    func loadingCompleted() -> Bool {
        switch self {
        case .loadingCompleted: return true
        default: return false
        }
    }
    
    init(errorCode: Int, description: String?) {
        switch errorCode {
        case -100: self = .tokenExpiredError
        case -101: self = .noSuchPost
        default: self = .other(description: description ?? "Request failed with no description for error code \(errorCode)")
        }
    }
}
