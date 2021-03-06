//
//  HollowTextView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct HollowTextView: View {
    var text: String
    var inDetail: Bool
    var highlight: Bool
    
    @ScaledMetric(wrappedValue: 16, relativeTo: .body) var body16: CGFloat
    
    var compactLineLimit: Int? = nil
    var body: some View {
        textView
            .font(.system(size: body16))
            .lineSpacing(3)
            .leading()
            .foregroundColor(inDetail ? .primary : .hollowContentText)
            .lineLimit(compactLineLimit)
    }
    
    @ViewBuilder var textView: some View {
        if highlight {
            Text.highlightLinksAndCitation(text, modifiers: {
                $0.underline()
                    .foregroundColor(.hollowContentText)
            })
        } else {
            Text(text)
        }
    }
}
