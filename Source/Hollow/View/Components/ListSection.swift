//
//  ListSection.swift
//  ListSection
//
//  Created by liang2kl on 2021/8/8.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct ListSection<Content: View>: View {
    var header: LocalizedStringKey? = nil
    var headerImage: String? = nil
    var footer: LocalizedStringKey? = nil
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        Section(footer: Group {
            if let footer = footer {
                Text(footer)
            }
        }) {
            if let header = header {
                Group {
                    if let imageName = headerImage {
                        Label(header, systemImage: imageName)
                    } else {
                        Text(header)
                    }
                }
                .dynamicFont(size: 16, weight: .semibold)
                .foregroundColor(.hollowContentText)
                .listRowBackground(Color.listHeaderRowBackground)
                .listRowSeparator(.hidden)

            }
            
            content()
        }
    }
}
