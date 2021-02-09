//
//  RequestError.swift
//  Hollow
//
//  Created by aliceinhollow on 9/2/2021.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

protocol RequestError: Error {
    // TODO: Localization
    associatedtype ErrorType
    var errorType: ErrorType { get set }
    var description: String { get }
}

/// DefaultRequestError for default request
enum DefaultRequestErrorType {
    case decodeFailed
    case tokenExpiredError
    case other(description: String)
}

struct DefaultRequestError: RequestError {
    var errorType: DefaultRequestErrorType?
    var description: String {
        switch self.errorType {
        case .tokenExpiredError: return "Token expired, please login."
        case .decodeFailed: return "Fail to decode tree hollow configuration from the URL."
        case .other(let description): return description
        case .none: return "Unknown error!" // should never be here
        }
    }
    // init by error code
    mutating func initbyCode(errorCode: Int, description: String?) {
        if errorCode == -100 {
            errorType = .tokenExpiredError
        }
        else{
            errorType = .other(description: description ?? "Unknown error!")
            //should never be after ??
        }
    }
}
