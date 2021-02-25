//
//  LoadingLabel.swift
//  Hollow
//
//  Created by 梁业升 on 2021/2/10.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct LoadingLabel: View {
    
    @ScaledMetric(wrappedValue: 16, relativeTo: .body) var body16: CGFloat
    @ScaledMetric(wrappedValue: 14, relativeTo: .body) var body14: CGFloat
    
    var body: some View {
        HStack {
            Text("LOADING_LABEL_TEXT")
                .font(.system(size: body16, weight: .medium))
            Spinner(color: .hollowContentText, desiredWidth: body14)
        }
        .foregroundColor(.hollowContentText)
    }
}

struct LoadingLabel_Previews: PreviewProvider {
    static var previews: some View {
        LoadingLabel()
    }
}
