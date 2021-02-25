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
    case noSuchPost
    /// Indicating that current request has finished successfully.
    case loadingCompleted
    case other(description: String)
    
    var description: String {
        switch self {
        case .tokenExpiredError: return NSLocalizedString("REQUEST_TOKEN_EXPIRED_ERROR_MSG", comment: "")
        case .decodeFailed: return NSLocalizedString("REQUEST_DECODE_FAILED_ERROR_MSG", comment: "")
        case .unknown: return NSLocalizedString("REQUEST_UNKNOWN_ERROR_MSG", comment: "")
        case .fileTooLarge: return NSLocalizedString("REQUEST_FILE_TOO_LARGE_ERROR_MSG", comment: "")
        case .noSuchPost: return NSLocalizedString("REQUEST_NO_SUCH_POST_ERROR_MSG", comment: "")
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
        default: self = .other(description: description ?? NSLocalizedString("REQUEST_OTHER_ERROR_NO_DESCRIPTION_WITH_CODE_MSG", comment: "") + "\(errorCode)")
        }
    }
}
