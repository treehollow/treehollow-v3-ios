//
//  DeviceListView.swift
//  Hollow
//
//  Created by 梁业升 on 2021/2/9.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct DeviceListView: View {
    @ObservedObject var deviceListStore = DeviceListStore()
    var body: some View {
        ScrollView {
            VStack {
                ForEach(deviceListStore.deviceData.devices.indices, id: \.self) { index in
                    DeviceCardView(
                        device: deviceListStore.deviceData.devices[index],
                        isCurrentDevice:
                            deviceListStore.deviceData.thisDeviceUUID ==
                            deviceListStore.deviceData.devices[index].deviceUUID,
                        isLoggingout: deviceListStore.loggingoutUUID == deviceListStore.deviceData.devices[index].deviceUUID,
                        logoutAction: deviceListStore.logout
                    )
                    .padding(.horizontal)
                    .padding(.top)
                    .disabled(deviceListStore.isLoading)
                }
                
                // Placeholder
                Spacer().horizontalCenter()
            }
        }
        .background(Color.background.ignoresSafeArea())
        .navigationTitle("Devices")
        .modifier(LoadingIndicator(isLoading: deviceListStore.isLoading, disableWhenLoading: false))
        .modifier(ErrorAlert(errorMessage: $deviceListStore.errorMessage))
        .navigationBarItems(trailing: Button(action: {
            deviceListStore.requestDeviceList(finishHandler: {})
        }) {
            Image(systemName: "arrow.clockwise")
        })
    }
}

extension DeviceListView {
    private struct DeviceCardView: View {
        var device: DeviceInformationType
        var isCurrentDevice: Bool
        var isLoggingout: Bool
        var logoutAction: (UUID) -> Void
        
        @ScaledMetric(wrappedValue: 15, relativeTo: .body) var body15: CGFloat
        @ScaledMetric(wrappedValue: 12, relativeTo: .body) var body12: CGFloat
        @ScaledMetric(wrappedValue: 14, relativeTo: .body) var body14: CGFloat
        @ScaledMetric(wrappedValue: 5, relativeTo: .body) var body5: CGFloat
        @ScaledMetric(wrappedValue: ViewConstants.plainButtonFontSize) var buttonFontSize: CGFloat
        
        var body: some View {
            VStack(alignment: .leading, spacing: body14) {
                section(header: "device" + (isCurrentDevice ? " (current)" : ""), content: device.deviceInfo)
                
                HStack(alignment: .bottom) {
                    section(header: "login date", content: String(device.loginDate.description.prefix(10)))
                    Spacer()
                    
                    // We won't allow the user to terminate the current
                    // device in device list.
                    if !isCurrentDevice {
                        MyButton(action: { logoutAction(device.deviceUUID) }, gradient: .vertical(gradient: .button)) { Group {
                            if isLoggingout {
                                Spinner(color: .white, desiredWidth: buttonFontSize)
                            } else {
                                Text("Logout")
                                    .fontWeight(.medium)
                                    .font(.system(size: buttonFontSize, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }}
                    }
                }
            }
            .padding()
            .background(
                Color.hollowCardBackground.overlay(
                    Text(device.deviceType.description)
                        .fontWeight(.semibold)
                        .font(.system(.title, design: .monospaced))
                        .foregroundColor(.uiColor(.systemFill))
                        .padding(.top)
                        .padding(.trailing)
                        .trailing()
                        .top()
                )
            )
            .cornerRadius(body15)
        }
        
        private func headerText(_ text: String) -> some View {
            Text(text.uppercased())
                .font(.system(size: body15, weight: .semibold))
                .foregroundColor(.hollowContentText)
        }
        
        private func section(header: String, content: String) -> some View {
            VStack(alignment: .leading, spacing: body5) {
                headerText(header.uppercased())
                Text(content)
                    .font(.system(.body, design: .monospaced))
            }
        }
    }
}

struct DeviceListView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceListView()
        //            .background(Color.background)
        //            .colorScheme(.dark)
    }
}
