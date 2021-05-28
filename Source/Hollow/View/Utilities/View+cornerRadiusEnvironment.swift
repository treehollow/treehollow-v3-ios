//
//  View+cornerRadiusEnvironment.swift
//  Hollow
//
//  Created by liang2kl on 2021/5/28.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func cornerRadiusEnvironment(radius: CGFloat) -> some View {
        self.environment(\.proposedRadius, radius)
    }
}

fileprivate struct RadiusKey: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}

extension EnvironmentValues {
    var proposedRadius: CGFloat? {
        get { self[RadiusKey.self] }
        set { self[RadiusKey.self] = newValue }
    }
}
