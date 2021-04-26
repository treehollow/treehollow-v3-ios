//
//  LoadingLabel.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/10.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct LoadingLabel: View {
    
    @ScaledMetric(wrappedValue: 14, relativeTo: .body) var body14: CGFloat
    
    var foregroundColor: Color = .hollowContentText
    
    var body: some View {
        HStack {
            Text("LOADING_LABEL_TEXT")
                .dynamicFont(size: 16, weight: .semibold)
            Spinner(color: foregroundColor, desiredWidth: body14)
        }
        .foregroundColor(foregroundColor)
    }
}
