//
//  UpdateAvailabilityRequest.swift
//  Hollow
//
//  Created by liang2kl on 2021/4/27.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Defaults
import Alamofire
import Combine

struct UpdateAvailabilityRequestResult: Codable {
    struct Result: Codable {
        var minimumOsVersion: String
        var trackViewUrl: String
        var currentVersionReleaseDate: String
        var releaseNotes: String
        var version: String
    }
    var results: [Result]
}

struct UpdateAvailabilityRequest: Request {
    typealias Configuration = Void
    typealias Result = UpdateAvailabilityRequestResult
    typealias ResultData = (Bool, UpdateAvailabilityRequestResult.Result)
    typealias Error = DefaultRequestError
    
    static var defaultPublisher: AnyPublisher<ResultData?, Never> {
        return UpdateAvailabilityRequest(configuration: ()).publisher
            .map({ Optional($0) })
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var configuration: Void
    
    init(configuration: Void) {
        self.configuration = configuration
    }
    
    func performRequest(completion: @escaping (ResultData?, DefaultRequestError?) -> Void) {
        #if targetEnvironment(macCatalyst)
        // FIXME: Seems that we cannot get macOS version info with the same bundle id.
        completion(nil, nil)
        #endif
        guard let info = Bundle.main.infoDictionary,
              let currentVersion = info["CFBundleShortVersionString"] as? String,
              let identifier = info["CFBundleIdentifier"] as? String,
              let url = URL(string: "http://itunes.apple.com/cn/lookup?bundleId=\(identifier)") else {
            completion(nil, .unknown)
            return
        }
        
        AF.request(url.absoluteString, method: .get)
            .validate()
            .responseJSON { response in
                guard let data = response.data else {
                    completion(nil, .unknown)
                    return
                }
                
                guard let result = try? JSONDecoder().decode(Result.self, from: data),
                      !result.results.isEmpty else {
                    completion(nil, .decodeFailed)
                    return
                }
                
                let updateAvailable = currentVersion != result.results.first!.version
                completion((updateAvailable, result.results.first!), nil)
            }
    }
}
