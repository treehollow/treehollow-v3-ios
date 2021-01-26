//
//  HollowHeader.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

class HollowHeader: ObservableObject {
    var starHandler: (Bool) -> Void
    
    init(starHandler: @escaping (Bool) ->Void) {
        self.starHandler = starHandler
    }
}
