//
//  View+defaultPadding.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/28.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func defaultPadding(_ edges: Edge.Set) -> some View {
        #if targetEnvironment(macCatalyst)
        return self.padding(edges, ViewConstants.macAdditionalPadding)
        #else
        return self.padding(edges)
        #endif
    }
}
