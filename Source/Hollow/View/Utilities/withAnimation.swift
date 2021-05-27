//
//  withAnimation.swift
//  Hollow
//
//  Created by liang2kl on 2021/5/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

/// Overriding the default `withAnimation` call with custom animation.
func withAnimation<Result>(_ body: () throws -> Result) rethrows -> Result {
    try SwiftUI.withAnimation(/*.spring(response: 0.4, dampingFraction: 0.88)*/.defaultSpring, body)
}
