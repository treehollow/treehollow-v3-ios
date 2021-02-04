//
//  HollowVerticalDivider.swift
//  Hollow
//
//  Created by 梁业升 on 2021/2/4.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct HollowVerticalDivider: View {
    var width: CGFloat = 3
    var body: some View {
        Rectangle()
            .frame(width: width)
    }
}

struct HollowVerticalDivider_Previews: PreviewProvider {
    static var previews: some View {
        HollowVerticalDivider()
    }
}
