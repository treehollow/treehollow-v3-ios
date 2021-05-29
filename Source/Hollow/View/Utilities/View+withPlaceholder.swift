//
//  View+withPlaceholder.swift
//  Hollow
//
//  Created by liang2kl on 2021/5/29.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    /// To hide the original view when used as source of `.matchedGeometryEffect()`
    @ViewBuilder func withPlaceholder<HashableValue: Hashable>(_ hide: Bool, namespace: Namespace.ID?, id: HashableValue) -> some View {
        if hide { self.opacity(0) }
        else { self.conditionalMatchedGeometryEffect(id: id, in: namespace) }
    }
}
