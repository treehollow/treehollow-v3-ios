//
//  TabView.swift
//  TabView
//
//  Created by liang2kl on 2021/8/22.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct TabView<SelectionValue, Content>: View where SelectionValue : Hashable, Content : View {
    @Binding var selection: SelectionValue
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        if #available(iOS 15, *) {
            SwiftUI.TabView(selection: $selection, content: content)
        } else {
            CustomTabView(selection: $selection, ignoreSafeAreaEdges: .bottom, content: content)
        }
    }
}
