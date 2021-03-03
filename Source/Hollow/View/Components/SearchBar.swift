//
//  SearchBar.swift
//  Hollow
//
//  Created by 梁业升 on 2021/3/3.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct SearchBar: View {
    @Binding var isSearching: Bool
    
    @ScaledMetric(wrappedValue: 17, relativeTo: .body) var body17: CGFloat

    var body: some View {
        Button(action:{
            // FIXME: Ugly animation here
            // Navigate to search view
            withAnimation(.searchViewTransition) {
                isSearching = true
            }
        }) {
            HStack {
                Image(systemName: "magnifyingglass")
                Text("TIMELINE_SEARCH_BAR_PLACEHOLDER")
                Spacer()
            }
            .font(.system(size: body17))
            .foregroundColor(.mainSearchBarText)
            .padding(.vertical, 7)
            .padding(.horizontal, 15)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.mainSearchBarBackground.opacity(0.6))
            )
            
        }
    }
}
