//
//  LinearGradient+vertical.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension LinearGradient {
    static func vertical(gradient: Gradient) -> LinearGradient {
        return LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom)
    }
}
