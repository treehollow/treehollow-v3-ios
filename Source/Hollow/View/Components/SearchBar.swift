//
//  SearchBar.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/3.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct SearchBar: View {
    @Binding var isSearching: Bool

    var body: some View {
        Button(action:{
            // Navigate to search view
            withAnimation(.defaultSpring) {
                isSearching = true
            }
        }) {
            HStack {
                Image(systemName: "magnifyingglass")
                Text("TIMELINE_SEARCH_BAR_PLACEHOLDER")
                Spacer()
            }
            .dynamicFont(size: 17)
            .foregroundColor(.mainPageUnselected)
            .padding(.vertical, 7)
            .padding(.horizontal, 15)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.hollowCardBackground.opacity(0.6))
            )
            
        }
    }
}
