//
//  DeviceListStore.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/9.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import Defaults

class DeviceListStore: ObservableObject, HollowErrorHandler {
    @Published var deviceData: DeviceListRequestResultData
    @Published var isLoading: Bool = false
    @Published var loggingoutUUID: String?
    @Published var errorMessage: (title: String, message: String)?
    
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Load the latest cache as placeholder
        deviceData = Defaults[.deviceListCache] ?? .init(devices: [], thisDeviceUUID: "")
    }
    
    func requestDeviceList() {
        guard let config = Defaults[.hollowConfig],
              let token = Defaults[.accessToken] else { return }
        let request = DeviceListRequest(configuration: .init(token: token, apiRoot: config.apiRootUrls))
        withAnimation {
            isLoading = true
        }
        
        request.publisher
            .sinkOnMainThread(receiveError: { error in
                withAnimation { self.isLoading = false }
                self.defaultErrorHandler(errorMessage: &self.errorMessage, error: error)
            }, receiveValue: { result in
                withAnimation { self.isLoading = false }
                var sortedResult = result
                var sortedDevices = result.devices
                // Sort the result by login date
                sortedDevices.sort(by: { $0.loginDate > $1.loginDate })
                // Put current device at 0
                if let currentDeviceIndex = sortedDevices.firstIndex(where: { $0.deviceUUID == result.thisDeviceUUID }) {
                    let currentDevice = sortedDevices[currentDeviceIndex]
                    sortedDevices.remove(at: currentDeviceIndex)
                    sortedDevices.insert(currentDevice, at: 0)
                }
                sortedResult.devices = sortedDevices
                withAnimation {
                    self.deviceData = sortedResult
                }
                
                // Store in Defaults for placeholder use
                Defaults[.deviceListCache] = sortedResult
            })
            .store(in: &cancellables)
    }
    
    func logout(deviceUUID: String) {
        guard let config = Defaults[.hollowConfig],
              let token = Defaults[.accessToken] else { return }
        let request = DeviceTerminationRequest(configuration: .init(deviceUUID: deviceUUID, token: token, apiRoot: config.apiRootUrls))
        
        withAnimation {
            isLoading = true
            loggingoutUUID = deviceUUID
        }
        
        request.publisher
            .sinkOnMainThread(receiveError: { error in
                withAnimation {
                    self.isLoading = false
                    self.loggingoutUUID = nil
                }
                self.defaultErrorHandler(errorMessage: &self.errorMessage, error: error)
            }, receiveValue: { result in
                withAnimation {
                    self.isLoading = false
                    self.loggingoutUUID = nil
                    let index = self.deviceData.devices.firstIndex(where: { $0.deviceUUID == deviceUUID })!
                    withAnimation {
                        self.deviceData.devices.remove(at: index)
                        Defaults[.deviceListCache] = self.deviceData
                    }
                }
            })
            .store(in: &cancellables)
    }
}
