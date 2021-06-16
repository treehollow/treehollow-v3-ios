//
//  View+defaultListStyle.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/8.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func defaultListStyle() -> some View {
        self
            .modifier(DefaultListStyle())
            .listStyle(InsetGroupedListStyle())
            .accentColor(.tint)
    }
}

fileprivate struct DefaultListStyle: ViewModifier {
    @ScaledMetric(wrappedValue: 52) var height: CGFloat
    
    func body(content: Content) -> some View {
        content
            .environment(\.defaultMinListRowHeight, height)
    }
}
