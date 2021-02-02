//
//  Image+imageButton.swift
//  Hollow
//
//  Created by 梁业升 on 2021/2/2.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension Image {
    func imageButton() -> some View {
        self
            .foregroundColor(.hollowContentText)
            .font(.system(size: 20, weight: .medium))
    }
}
