//
//  AppModel.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/15.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Combine
import Defaults
import Connectivity
import SwiftUI

class AppModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isInMainView = Defaults[.accessToken] != nil && Defaults[.hollowConfig] != nil
    
    var connectedToNetwork = Connectivity().status.isConnected
    
    init() {
        ConnectivityPublisher()
            .map { $0.status.isConnected }
            .removeDuplicates(by: { $0 == $1 })
            .sinkOnMainThread(receiveValue: { connected in
                if connected { LineSwitchManager.testAll() }
            })
            .store(in: &cancellables)
    }
}
