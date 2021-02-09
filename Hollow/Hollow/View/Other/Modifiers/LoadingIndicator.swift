//
//  LoadingIndicator.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/9.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct LoadingIndicator: ViewModifier {
    var isLoading: Bool
    var disableWhenLoading: Bool = true
    
    @Environment(\.colorScheme) var colorScheme
    
    @ScaledMetric(wrappedValue: 16, relativeTo: .body) var fontSize: CGFloat
    @ScaledMetric(wrappedValue: 5, relativeTo: .body) var body5: CGFloat
    @ScaledMetric(wrappedValue: 10, relativeTo: .body) var body10: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay(
                Group { if isLoading {
                    HStack {
                        Text(String.loadingLocalized.capitalized)
                        Spinner(color: .primary, desiredWidth: fontSize)
                    }
                    .font(.system(size: fontSize, weight: .semibold))
                    .padding(.horizontal, body10)
                    .padding(.vertical, body5)
                    .background(Color.background)
                    .colorScheme(colorScheme == .dark ? .light : .dark)
                    .clipShape(Capsule())
                    .transition(.move(edge: .top))
                    .padding(.top)
                    .top()
                }}
            )
            .disabled(isLoading && disableWhenLoading)
    }
}

#if DEBUG
struct LoadingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DeviceListView()
        }
        .modifier(LoadingIndicator(isLoading: true))
    }
}
#endif
