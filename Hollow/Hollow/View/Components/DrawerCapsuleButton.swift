//
//  DrawerCapsuleButton.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/12.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct DrawerCapsuleButton<PrimaryView, SupplymentaryView>: View where PrimaryView: View, SupplymentaryView: View {
    var expanded: Bool
    var height: CGFloat?
    var primaryAction: () -> Void
    var supplymentaryAction: () -> Void
    var primaryView: () -> PrimaryView
    var supplymentaryView: () -> SupplymentaryView
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Supplymentary
            Button(action: supplymentaryAction) {
                ZStack {
                    Capsule()
                        .foregroundColor(.background)
                        .frame(width: expanded ? nil : height, height: height)
                    HStack(spacing: 0) {
                        if expanded {
                            Spacer(minLength: height).fixedSize()
                        }
                        supplymentaryView()
                            .frame(width: expanded ? nil : height)
                    }
                }
                .fixedSize()
            }
            
            // Primary
            Button(action: primaryAction) {
                primaryView()
                    .frame(height: height)
                    .clipShape(Circle())
            }
        }
    }
}
