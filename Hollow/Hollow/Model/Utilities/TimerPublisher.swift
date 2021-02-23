//
//  TimerPublisher.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/23.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Combine

extension Timer {
    static let timeChangePublisher = Timer.publish(every: 10, on: RunLoop.main, in: .default)
}
