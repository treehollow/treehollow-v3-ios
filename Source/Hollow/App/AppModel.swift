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

class AppModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isInMainView = Defaults[.accessToken] != nil
    
    // Only for indicating expired state in `WelcomeView`
    @Published var tokenExpired = false
    
    var connectedToNetwork = Connectivity().status.isConnected
    
    init() {
        ConnectivityPublisher()
            .map { $0.status.isConnected }
            .sinkOnMainThread(receiveValue: { _ in
                LineSwitchManager.testAll()
            })
            .store(in: &cancellables)
    }
}
