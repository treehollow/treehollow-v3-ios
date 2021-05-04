//
//  View+defaultToggleStyle.swift
//  Hollow
//
//  Created by liang2kl on 2021/5/1.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func defaultToggleStyle() -> some View {
        return self
            .labelsHidden()
            .toggleStyle(SwitchToggleStyle(tint: .tint))
    }
}
