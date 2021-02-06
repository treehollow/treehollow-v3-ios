//
//  HollowContent.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/22.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Combine

class HollowContent: ObservableObject {
    var voteHandler: (String) -> Void
    
    init(voteHandler: @escaping (String) -> Void) {
        self.voteHandler = voteHandler
    }
}
