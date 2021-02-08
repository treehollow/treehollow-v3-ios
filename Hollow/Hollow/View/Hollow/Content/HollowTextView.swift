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
    
    @ScaledMetric(wrappedValue: 16, relativeTo: .body) var body16: CGFloat

    var compactLineLimit: Int? = nil
    var body: some View {
        Text(text)
            .font(.system(size: body16))
            .lineSpacing(3)
            .leading()
            .foregroundColor(.hollowContentText)
            .lineLimit(compactLineLimit)
    }
}

#if DEBUG
struct HollowTextView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            HollowTextView(text: testComments[0].text,
            compactLineLimit: nil)
        }
    }
}
#endif
