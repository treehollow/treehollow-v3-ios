//
//  HollowStarButton.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct HollowStarButton: View {
    var attention: Bool?
    var likeNumber: Int
    // For convenience
    var starHandler: (Bool) -> Void
    var body: some View {
        if let starred = self.attention {
            HollowButton(number: likeNumber, action: { starHandler(!starred) }, systemImageName: starred ? "star.fill" : "star")
                .foregroundColor(starred ? .hollowCardStarSelected : .hollowCardStarUnselected)
        } else {
            Spinner(color: .hollowCardStarUnselected, desiredWidth: 16)
        }
    }
}

struct HollowButton: View {
    var number: Int

    var action: () -> Void
    var systemImageName: String
    
    @ScaledMetric(wrappedValue: 16, relativeTo: .body) var body16: CGFloat

    var body: some View {
        Button(action: action) {
            HStack(spacing: 3) {
                Text("\(number.string)")
                Image(systemName: systemImageName)
            }
            .font(.system(size: body16, weight: .semibold, design: .rounded))
        }
        .padding(5)
    }
}

#if DEBUG
struct HollowStarButton_Previews: PreviewProvider {
    static var previews: some View {
        HollowStarButton(attention: false, likeNumber: 10, starHandler: {_ in})
        HollowStarButton(attention: true, likeNumber: 10, starHandler: {_ in})
        HollowStarButton(attention: nil, likeNumber: 10, starHandler: {_ in})
    }
}
#endif
