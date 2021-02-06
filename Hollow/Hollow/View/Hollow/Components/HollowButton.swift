//
//  HollowStarButton.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct HollowStarButton: View {
    @Binding var attention: Bool?
    @Binding var likeNumber: Int
    // For convenience
    var starHandler: (Bool) -> Void
    var body: some View {
        if let starred = self.attention {
            HollowButton(number: $likeNumber, action: { starHandler(!starred) }, systemImageName: starred ? "star.fill" : "star")
                .foregroundColor(starred ? .hollowCardStarSelected : .hollowCardStarUnselected)
        } else {
            Spinner(color: .hollowCardStarUnselected, desiredWidth: 16)
        }
    }
}

struct HollowButton: View {
    @Binding var number: Int

    var action: () -> Void
    var systemImageName: String
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 3) {
                Text("\(number.string)")
                Image(systemName: systemImageName)
            }
            .font(.dynamic(size: 16, weight: .semibold, design: .rounded))
        }
        .padding(5)
    }
}

struct HollowStarButton_Previews: PreviewProvider {
    static var previews: some View {
        HollowStarButton(attention: .constant(false), likeNumber: .constant(10), starHandler: {_ in})
        HollowStarButton(attention: .constant(true), likeNumber: .constant(10), starHandler: {_ in})
        HollowStarButton(attention: .constant(nil), likeNumber: .constant(10), starHandler: {_ in})
    }
}
