//
//  FloatButton.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/11.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct FloatButton: View {
    var action: () -> Void
    var systemImageName: String
    var imageScaleFactor: CGFloat = 1
    let buttonAnimationNamespace: Namespace.ID
    
    @ScaledMetric(wrappedValue: 30, relativeTo: .body) var body30: CGFloat
    @ScaledMetric(wrappedValue: 50, relativeTo: .body) var body50: CGFloat
    
    @Environment(\.isEnabled) var isEnabled
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: body50 / 2, style: .continuous)
                    .matchedGeometryEffect(id: "button", in: buttonAnimationNamespace)
                    .frame(width: body50, height: body50)
                    .foregroundColor(.hollowContentVoteGradient1)

                Image(systemName: systemImageName)
                    .font(.system(size: body30 * imageScaleFactor))
                    .foregroundColor(.white)
            }
        }
        .shadow(radius: 5)
        .opacity(isEnabled ? 1 : 0.5)
    }
}
