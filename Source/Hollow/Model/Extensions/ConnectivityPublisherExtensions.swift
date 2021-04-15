//
//  ConnectivityPublisherExtensions.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/27.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Connectivity

extension ConnectivityPublisher {
    static let networkConnectedStatusPublisher = networkChangePublisher
        .removeDuplicates(by: { $0 == $1 })
        .dropFirst()
    
    private static let networkChangePublisher = ConnectivityPublisher()
        .map { $0.status.isConnected }
}
