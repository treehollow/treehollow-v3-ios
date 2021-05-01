//
//  VersionUpdateView.swift
//  Hollow
//
//  Created by liang2kl on 2021/4/27.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

struct VersionUpdateView: View {
    let info: UpdateAvailabilityRequestResult.Result
    var showItem: Bool
    @Environment(\.openURL) var openURL
    
    var body: some View {
        List {
            Section {
                ImageTitledStack(systemImageName: "rays") {
                    Text("VERSION_UPDATE_VIEW_WHATS_NEW")
                        .font(.headline)
                        .padding(.bottom, 5)
                    Text(verbatim: info.releaseNotes)
                        .foregroundColor(.secondary)
                        .dynamicFont(size: 16)
                }
                .padding(.vertical)
                
                TextualLabel(primaryText: "VERSION_UPDATE_VIEW_VERSION", secondaryText: info.version, options: .monospaced)
                TextualLabel(primaryText: "VERSION_UPDATE_VIEW_RELEASE_DATE", secondaryText: String(info.currentVersionReleaseDate.prefix(10)), options: .monospaced)
                TextualLabel(primaryText: "VERSION_UPDATE_VIEW_MIN_OS_VERSION", secondaryText: info.minimumOsVersion, options: .monospaced)

            }

            Button("VERSION_UPDATE_VIEW_GO") {
                if let url = URL(string: info.trackViewUrl) {
                    openURL(url)
                }
            }
        }
        .defaultListStyle()
        .navigationTitle(Text("VERSION_UPDATE_VIEW_NAV_TITLE"))
        .navigationBarItems(leading: Group { if showItem {
            Button("VERSION_UPDATE_VIEW_CLOSE", action: dismissSelf).accentColor(.tint)
        }})
    }
}
