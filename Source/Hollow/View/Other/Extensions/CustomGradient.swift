//
//  CustomGradient.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension Gradient {
    
    static var clear: Gradient {
        return Gradient(colors: [.clear, .clear])
    }
    
    static var hollowContentVote: Gradient {
        return Gradient(colors: [.hollowContentVoteGradient1, .hollowContentVoteGradient2])
    }
    
    static var button: Gradient {
        return Gradient(colors: [.buttonGradient1, .buttonGradient2])
    }
    
    func opacity(_ opacity: Double) -> Gradient {
        let stops: [Gradient.Stop] = self.stops.map({
            var stop = $0
            stop.color = stop.color.opacity(opacity)
            return stop
        })
        return Gradient(stops: stops)
    }
}
