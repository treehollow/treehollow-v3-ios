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
    
    @ScaledMetric(wrappedValue: 30, relativeTo: .body) var body30: CGFloat
    @ScaledMetric(wrappedValue: 50, relativeTo: .body) var body50: CGFloat
    
    @Environment(\.isEnabled) var isEnabled
    
    var body: some View {
        Button(action: action) {
            ZStack {
                LinearGradient.vertical(gradient: .hollowContentVote)
                Image(systemName: systemImageName)
                    .font(.system(size: body30 * imageScaleFactor))
                    .foregroundColor(.white)
            }
        }
        .frame(width: body50, height: body50)
        .clipShape(Circle())
        .opacity(isEnabled ? 1 : 0.5)
    }
}
