//
//  DeviceListStore.swift
//  Hollow
//
//  Created by 梁业升 on 2021/2/9.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import Defaults

class DeviceListStore: ObservableObject {
    @Published var deviceData: DeviceListRequestResultData
    @Published var isLoading: Bool = true
    @Published var loggingoutUUID: String?
    @Published var errorMessage: (title: String, message: String)?
    
    init() {
        deviceData = .init(devices: [], thisDeviceUUID: "")
        
        // Request data
        requestDeviceList(finishHandler: {})
    }
    
    func requestDeviceList(finishHandler: @escaping () -> Void) {
        let apiRoot = Defaults[.hollowConfig]!.apiRoot
        let request = DeviceListRequest(configuration: .init(token: Defaults[.accessToken]!, apiRoot: apiRoot))
        withAnimation {
            isLoading = true
        }
        request.performRequest(completion: { result, error in
            finishHandler()
            withAnimation {
                self.isLoading = false
            }
            if let error = error {
                self.errorMessage = (String.errorLocalized.capitalized, error.description)
                return
            }
            var sortedResult = result!
            var sortedDevices = result!.devices
            // Sort the result by login date
            sortedDevices.sort(by: { $0.loginDate > $1.loginDate })
            // Put current device at 0
            if let currentDeviceIndex = sortedDevices.firstIndex(where: { $0.deviceUUID == result!.thisDeviceUUID }) {
                sortedDevices.swapAt(0, currentDeviceIndex)
            }
            sortedResult.devices = sortedDevices
            withAnimation {
                self.deviceData = sortedResult
            }
            print(self.deviceData)
        })
    }
    
    func logout(deviceUUID: String) {
        let token = Defaults[.accessToken]!
        let apiRoot = Defaults[.hollowConfig]!.apiRoot
        let request = DeviceTerminationRequest(configuration: .init(deviceUUID: deviceUUID, token: token, apiRoot: apiRoot))
        
        withAnimation {
            isLoading = true
            loggingoutUUID = deviceUUID
        }
        request.performRequest(completion: { result, error in
            withAnimation {
                self.isLoading = false
                self.loggingoutUUID = nil
            }
            if let error = error {
                self.errorMessage = (String.errorLocalized.capitalized, error.description)
                return
            }
            guard let result = result else {
                self.errorMessage = (String.errorLocalized.capitalized, NSLocalizedString("Fail to log out the device.", comment: ""))
                return
            }
            switch result {
            case .success:
                let index = self.deviceData.devices.firstIndex(where: { $0.deviceUUID == deviceUUID })!
                _ = withAnimation {
                    self.deviceData.devices.remove(at: index)
                }
            }
        })
    }
}
