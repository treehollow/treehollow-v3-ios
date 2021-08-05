//
//  SettingsView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI
import Defaults

struct SettingsView: View {
    @Binding var presented: Bool
    @Default(.versionUpdateInfoCache) var versionUpdateInfoCache
    
    @State private var date = Date().startOfDay
    @ScaledMetric(wrappedValue: 20) var avatarWidth: CGFloat
    
    var body: some View {
        List {
            if !UIDevice.isPad {
                NavigationLink(
                    destination: AccountInfoView(),
                    label: {
                        Text("ACCOUNTVIEW_ACCOUNT_CELL")
                    })
            }
            
            Section {
                NavigationLink(NSLocalizedString("SETTINGSVIEW_APPEARANCE_NAV_TITLE", comment: ""), destination: AppearanceSettingsView())
                NavigationLink(NSLocalizedString("SETTINGSVIEW_CONTENT_NAV_TITLE", comment: ""), destination: ContentSettingsView())
                NavigationLink(NSLocalizedString("SETTINGSVIEW_NOTIFICATION_NAV_TITLE", comment: ""), destination: PushNotificationSettingsView(viewModel: .init()))
                NavigationLink(NSLocalizedString("SETTINGSVIEW_OTHER_NAV_TITLE", comment: ""), destination: OtherSettingsView())
            }
            
            if !UIDevice.isPad {
                NavigationLink(
                    destination: ProviderInfoView(),
                    label: {
                        HStack {
                            Text("SETTINGSVIEW_PROVIDER_SECTION_TITLE")
                            Spacer()
                            Text(Defaults[.hollowConfig]?.name ?? "")
                                .foregroundColor(.secondary)
                        }
                    })
                
                Section {
                    NavigationLink(
                        destination: AboutView(),
                        label: {
                            let appInfo = "\(Constants.Application.appVersion) (\(Constants.Application.buildVersion))"
                            TextualLabel(primaryText: "ACCOUNTVIEW_ABOUT_CELL", secondaryText: appInfo)
                        })
                    
                    if let cache = versionUpdateInfoCache {
                        NavigationLink(
                            "VERSION_UPDATE_VIEW_NAV_TITLE",
                            destination: VersionUpdateView(info: cache, showItem: false)
                        )
                    }
                }
            }
            
        }
        .defaultListStyle()
        .navigationBarTitle(NSLocalizedString("SETTINGSVIEW_NAV_TITLE", comment: ""), displayMode: UIDevice.isPad ? .automatic : .inline)
        .navigationBarItems(leading: Group {
            if !UIDevice.isPad {
                Button(action: { presented = false }) {
                    Image(systemName: "xmark")
                        .padding(5)
                        .foregroundColor(.hollowContentText)
                }
            }
        })
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(.tint)
    }
}
