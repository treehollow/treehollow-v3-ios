//
//  DeviceListView.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/9.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct DeviceListView: View {
    @ObservedObject var deviceListStore = DeviceListStore()
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(deviceListStore.deviceData.devices, id: \.deviceUUID) { device in
                    DeviceCardView(
                        device: device,
                        isCurrentDevice:
                            deviceListStore.deviceData.thisDeviceUUID ==
                            device.deviceUUID,
                        isLoggingout:
                            deviceListStore.loggingoutUUID ==
                            device.deviceUUID,
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
        .modifier(LoadingIndicator(isLoading: deviceListStore.isLoading))
        .modifier(ErrorAlert(errorMessage: $deviceListStore.errorMessage))
        .navigationBarItems(trailing: Button(action: deviceListStore.requestDeviceList) {
            Image(systemName: "arrow.clockwise")
        })
    }
}

extension DeviceListView {
    private struct DeviceCardView: View {
        var device: DeviceInformationType
        var isCurrentDevice: Bool
        var isLoggingout: Bool
        var logoutAction: (String) -> Void
        
//        @State private var alertPresented = false
        
        @ScaledMetric(wrappedValue: 15, relativeTo: .body) var body15: CGFloat
        @ScaledMetric(wrappedValue: 12, relativeTo: .body) var body12: CGFloat
        @ScaledMetric(wrappedValue: 14, relativeTo: .body) var body14: CGFloat
        @ScaledMetric(wrappedValue: 5, relativeTo: .body) var body5: CGFloat
        @ScaledMetric(wrappedValue: ViewConstants.plainButtonFontSize) var buttonFontSize
        
        var body: some View {
            VStack(alignment: .leading, spacing: body14) {
                section(header: "device" + (isCurrentDevice ? " (current)" : ""), content: device.deviceInfo)
                
                HStack(alignment: .bottom) {
                    section(header: "login date", content: String(device.loginDate.description.prefix(10)))
                    Spacer()
                    
                    // We won't allow the user to terminate the current
                    // device in device list.
                    if !isCurrentDevice {
                        MyButton(action: { logoutAction(device.deviceUUID) }, gradient: .vertical(gradient: .button)) {
                            Group {
                                if isLoggingout {
                                    Text("Processing" + "...")
                                } else {
                                    Text("Logout")
                                }
                            }
                            .font(.system(size: buttonFontSize, weight: .bold))
                            .foregroundColor(.white)
                        }
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
            .cornerRadius(15)
            
            // FIXME: Cannot present alert
//            .alert(isPresented: $alertPresented, content: {
//                Alert(
//                    title: Text("Logout"),
//                    message: Text("\(device.deviceInfo)"),
//                    primaryButton: .cancel(),
//                    secondaryButton: .destructive(Text("Logout"), action: { logoutAction(device.deviceUUID) })
//                )
//            })
        }
        
        private func section(header: String, content: String) -> some View {
            VStack(alignment: .leading, spacing: body5) {
                Text(header.uppercased())
                    .font(.system(size: body15, weight: .semibold))
                    .foregroundColor(.hollowContentText)
                Text(content)
                    .font(.system(.body, design: .monospaced))
            }
        }
    }
}

#if DEBUG
struct DeviceListView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceListView()
        //            .background(Color.background)
        //            .colorScheme(.dark)
    }
}
#endif
