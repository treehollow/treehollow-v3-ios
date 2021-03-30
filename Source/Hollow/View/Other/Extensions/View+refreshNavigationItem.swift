//
//  View+refreshNavigationItem.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/30.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func refreshNavigationItem(refreshAction: @escaping () -> Void) -> some View {
        return self
            .navigationBarItems(leading: EmptyView(), trailing: Group {
                #if targetEnvironment(macCatalyst)
                Button(action: refreshAction) {
                    Image(systemName: "arrow.clockwise")
                }
                #endif
            })
    }
}
