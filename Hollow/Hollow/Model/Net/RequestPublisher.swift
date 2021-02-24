//
//  RequestPublisher.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/22.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Combine

struct RequestPublisher<R>: Publisher where R: Request {
    
    typealias Output = R.ResultData
    typealias Failure = R.Error
    
    let configuration: R.Configuration
    
    func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subsription = RequestSubscription(request: R(configuration: configuration), subscriber: subscriber)
        subscriber.receive(subscription: subsription)
    }
}

fileprivate class RequestSubscription<S: Subscriber, R: Request>: Subscription where S.Input == R.ResultData, S.Failure == R.Error {
    private let request: R
    private var subscriber: S?
    
    init(request: R, subscriber: S) {
        self.request = request
        self.subscriber = subscriber
    }
    
    func request(_ demand: Subscribers.Demand) {
        guard let subscriber = subscriber else { return }
        request.performRequest(completion: { result, error in
            if let result = result {
                _ = subscriber.receive(result)
            }
            if let error = error {
                if error.loadingCompleted() {
                    // Send finish message
                    subscriber.receive(completion: .finished)
                } else {
                    subscriber.receive(completion: .failure(error))
                }
            }
        })
    }
    
    func cancel() {
        subscriber = nil
    }
}

