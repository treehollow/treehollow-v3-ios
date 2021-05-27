//
//  View+conditionalMatchedGeometryEffect.swift
//  Hollow
//
//  Created by liang2kl on 2021/5/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder func conditionalMatchedGeometryEffect<ID: Hashable>(id: ID, in namespace: Namespace.ID?, properties: MatchedGeometryProperties = .frame, anchor: UnitPoint = .center, isSource: Bool = true) -> some View {
        if let namespace = namespace {
            self.matchedGeometryEffect(id: id, in: namespace, properties: properties, anchor: anchor, isSource: isSource)
        } else {
            self
        }
    }
}
