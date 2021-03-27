//
//  View+conditionalSizeCategory.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/27.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func conditionalSizeCategory(categoryForMacCatalyst: ContentSizeCategory = .extraLarge) -> some View {
        #if targetEnvironment(macCatalyst)
        return self
            .environment(\.sizeCategory, categoryForMacCatalyst)
        #else
        return self
        #endif
    }
}
