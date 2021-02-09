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
    case unknown
    case unknownBackend
    case other(description: String)
    
    var description: String {
        switch self {
        case .tokenExpiredError: return "Token expired, please login again."
        case .decodeFailed: return "Fail to decode tree hollow configuration from the URL."
        case .unknown: return "Fail to initialize data. This is an internal error."
        case .unknownBackend: return "The backend returns data with unknown error. This is an internal error."
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
