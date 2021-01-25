//
//  CustomGradient.swift
//  Hollow
//
//  Created by 梁业升 on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension Gradient {
    static var clear: Gradient {
        return Gradient(colors: [.clear, .clear])
    }
    static var hollowContentVoteGradient: Gradient {
        return Gradient(colors: [.hollowContentVoteGradient1, .hollowContentVoteGradient2])
    }
}
