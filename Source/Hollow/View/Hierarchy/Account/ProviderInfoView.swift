//
//  ProviderInfoView.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/15.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

struct ProviderInfoView: View {
    @Default(.hiddenAnnouncement) var hiddenAnnouncement
    @Environment(\.openURL) var openURL
    
    var body: some View {
        List {
            if let announcement = Defaults[.hollowConfig]?.announcement {
                ListSection(header: "TIMELINEVIEW_ANNOUCEMENT_CARD_TITLE", headerImage: "megaphone") {
                    Text(announcement)
                        .foregroundColor(.secondary)
                        .dynamicFont(size: 14)
                        .padding(.vertical, 5)
                    
                    if announcement == hiddenAnnouncement {
                        Button("PROVIDER_VIEW_RESTORE_ANNOUNCEMENT") {
                            withAnimation {
                                hiddenAnnouncement = ""
                            }
                        }
                        .accentColor(.tint)
                    }
                }
            }
            
            Button("ACCOUNTVIEW_RULES_CELL") {
                if let urlString = Defaults[.hollowConfig]?.rulesUrl,
                   let url = URL(string: urlString) {
                    IntegrationUtilities.presentSafariVC(url: url)
                }
            }

            Section {
                Button("LOGINVIEW_REGISTER_TOS_BUTTON") {
                    if let urlString = Defaults[.hollowConfig]?.tosUrl,
                       let url = URL(string: urlString) {
                        IntegrationUtilities.presentSafariVC(url: url)
                    }
                }
                Button("LOGINVIEW_REGISTER_PRIVACY_BUTTON") {
                    if let urlString = Defaults[.hollowConfig]?.privacyUrl,
                       let url = URL(string: urlString) {
                        IntegrationUtilities.presentSafariVC(url: url)
                    }
                }
            }
            
            if let contactEmail = Defaults[.hollowConfig]?.contactEmail,
               let url = URL(string: "mailto:" + contactEmail) {
                Button(action: { openURL(url) }) {
                    HStack {
                        Text("PROVIDER_VIEW_CONTACT")
                        Spacer()
                        Text(contactEmail)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .accentColor(.primary)
        .navigationBarTitle(Defaults[.hollowConfig]?.name ?? NSLocalizedString("SETTINGSVIEW_PROVIDER_SECTION_TITLE", comment: ""))
        .defaultListStyle()
    }
}
