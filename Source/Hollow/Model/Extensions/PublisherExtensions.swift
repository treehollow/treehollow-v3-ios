//
//  PublisherExtensions.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/23.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Combine
import SwiftUI

extension Publisher {
    /// Wrap `.sink` on main thread.
    func sinkOnMainThread(receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void, receiveValue: @escaping (Self.Output) -> Void) -> AnyCancellable {
        return self
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
    }
    
    /// Wrap `.sink` on main thread, while ignoring `Subscribers.Completion.finished`.
    func sinkOnMainThread(receiveError: @escaping ((Self.Failure) -> Void), receiveValue: @escaping (Self.Output) -> Void) -> AnyCancellable {
        return self
            .receive(on: DispatchQueue.main)
            .sink(receiveError: receiveError, receiveValue: receiveValue)
    }
    
    /// `.sink` ignoring `Subscribers.Completion.finished`.
    func sink(receiveError: @escaping ((Self.Failure) -> Void), receiveValue: @escaping (Self.Output) -> Void) -> AnyCancellable {
        return self
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        receiveError(error)
                    default: break
                    }
                },
                receiveValue: receiveValue
            )
    }
    
    /// Transform `Output` to optional.
    func nullable() -> AnyPublisher<Output?, Failure> {
        return self
            .map { Optional($0) }
            .eraseToAnyPublisher()
    }

}

extension Publisher where Failure == Never {
    
    func sinkOnMainThread(receiveValue: @escaping (Self.Output) -> Void) -> AnyCancellable {
        return self
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: receiveValue)
    }
    
    func sinkOnMainThread(completion: @escaping () -> Void, receiveValue: @escaping (Self.Output) -> Void) -> AnyCancellable {
        return self
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in completion() },
                receiveValue: receiveValue
            )
    }
}
