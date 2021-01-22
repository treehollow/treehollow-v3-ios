//
//  URLSessionPublisher.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/20.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Combine

struct URLSessionPublisher<Result>: Publisher {
    typealias Output = Result
    typealias Failure = URLError
    
    func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
//        let subscription = EventS
    }
}
