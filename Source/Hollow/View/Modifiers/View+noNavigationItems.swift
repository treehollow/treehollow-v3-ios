//
//  View+noNavigationItems.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/27.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func noNavigationItems() -> some View {
        self
            .navigationBarItems(leading: EmptyView(), trailing: EmptyView())
    }
}
