//
//  View+defaultListRow.swift
//  Hollow
//
//  Created by liang2kl on 2021/7/31.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func defaultListRow(backgroundColor: Color = .clear) -> some View {
        self
            .listRowBackground(backgroundColor)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listSectionSeparator(.hidden)
            .buttonStyle(.borderless)
            .environment(\.defaultMinListRowHeight, 0)
    }
}
