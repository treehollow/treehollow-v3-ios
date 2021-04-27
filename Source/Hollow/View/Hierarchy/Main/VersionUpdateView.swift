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
            Section { VStack(alignment: .leading, spacing: 5) {
                Image(systemName: "app.badge")
                    .foregroundColor(.tint)
                    .font(.largeTitle)
                    .padding(.bottom)
                
                Text("VERSION_UPDATE_VIEW_VERSION")
                    .foregroundColor(.tint)
                    .font(.system(.headline, design: .rounded))
                
                Text(verbatim: info.version)
                    .font(.system(.body, design: .monospaced))
                    .padding(.bottom, 10)
                
                Text("VERSION_UPDATE_VIEW_RELEASE_DATE")
                    .foregroundColor(.tint)
                    .font(.system(.headline, design: .rounded))
                
                Text(info.currentVersionReleaseDate.prefix(10))
                    .font(.system(.body, design: .monospaced))
                    .padding(.bottom, 10)
                
                Text("VERSION_UPDATE_VIEW_WHATS_NEW")
                    .foregroundColor(.tint)
                    .font(.system(.headline, design: .rounded))
                
                Text(verbatim: info.releaseNotes)
                    .padding(.bottom, 10)
                
                Text("VERSION_UPDATE_VIEW_MIN_OS_VERSION")
                    .foregroundColor(.tint)
                    .font(.system(.headline, design: .rounded))
                
                Text(verbatim: info.minimumOsVersion)
                    .font(.system(.body, design: .monospaced))
            }}
            .padding(.vertical)
            
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
