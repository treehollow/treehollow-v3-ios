//
//  Image+imageButton.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/2.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension Image {
    func imageButton() -> some View {
        self
            .foregroundColor(.hollowContentText)
            .font(.dynamic(size: 20, weight: .medium))
    }
}
