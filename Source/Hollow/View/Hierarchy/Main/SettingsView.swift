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
    
    var appInfo: String {
        let info = Constants.Application.appLocalizedName +
            NSLocalizedString("APPINFO_VERSION_PREFIX", comment: "") +
            Constants.Application.appVersion +
            " (\(Constants.Application.buildVersion))"
        #if DEBUG
        return "DEBUG VERSION\n" + info
        #else
        return info
        #endif
    }
    
    var body: some View {
        List {
            if !UIDevice.isPad {
                Section(header: Text("")) {
                    NavigationLink(
                        destination: AccountInfoView(),
                        label: {
                            Text("ACCOUNTVIEW_ACCOUNT_CELL")
                        })
                }
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
                
                Section(
                    footer: Text(appInfo)
                        .padding(.horizontal)
                ) {
                    NavigationLink(
                        destination: AboutView(),
                        label: {
                            Text("ACCOUNTVIEW_ABOUT_CELL")
                        })
                    
                    if let cache = versionUpdateInfoCache {
                        NavigationLink(
                            destination: VersionUpdateView(info: cache, showItem: false),
                            label: {
                                Text("VERSION_UPDATE_VIEW_NAV_TITLE")
                            })
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
                        .imageScale(.medium)
                        .foregroundColor(.hollowContentText)
                }
            }
        })
        .navigationViewStyle(StackNavigationViewStyle())
        .environment(\.imageScale, .large)
        .accentColor(.tint)
    }
}
