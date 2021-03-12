//
//  SettingsView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct SettingsView: View {
    @Binding var presented: Bool

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
        NavigationView {
            List {
                Section(header: Text("")) {
                    NavigationLink(
                        destination: AccountInfoView(),
                        label: {
                            Text("ACCOUNTVIEW_ACCOUNT_CELL")
                        })
                }
                Section {
                    NavigationLink(NSLocalizedString("SETTINGSVIEW_APPEARANCE_NAV_TITLE", comment: ""), destination: AppearanceSettingsView())
                    NavigationLink(NSLocalizedString("SETTINGSVIEW_CONTENT_NAV_TITLE", comment: ""), destination: ContentSettingsView())
                    NavigationLink(NSLocalizedString("SETTINGSVIEW_NOTIFICATION_NAV_TITLE", comment: ""), destination: PushNotificationSettingsView())
                    NavigationLink(NSLocalizedString("SETTINGSVIEW_OTHER_NAV_TITLE", comment: ""), destination: OtherSettingsView())
                }
                
                NavigationLink(
                    destination: Text(""),
                    label: {
                        Text("ACCOUNTVIEW_RULES_CELL")
                    })
                                
//                Section {
//                    // TODO: shows only when available
//                    Button(action: {}) {
//                        Text("ACCOUNTVIEW_UPDATE_CELL")
//                            .padding(.horizontal, listContentPadding)
//                    }
//
//                }
                
                Section(
                    footer: Text(appInfo)
                        .padding(.horizontal)
                ) {
                    NavigationLink(
                        destination: AboutView(),
                        label: {
                            Text("ACCOUNTVIEW_ABOUT_CELL")
                        })
                }

                
            }
            .defaultListStyle()
            .navigationBarTitle(NSLocalizedString("SETTINGSVIEW_NAV_TITLE", comment: ""), displayMode: .inline)
            .navigationBarItems(leading: Button(action: { presented = false }) {
                Image(systemName: "xmark")
                    .padding(5)
                    .imageScale(.medium)
                    .foregroundColor(.hollowContentText)
            })
        }
        .environment(\.imageScale, .large)
        .accentColor(.tint)
    }
}

#if DEBUG
struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(presented: .constant(true))
    }
}
#endif
