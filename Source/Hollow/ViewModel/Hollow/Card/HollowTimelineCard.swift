//
//  HollowTimelineCard.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Combine

class HollowTimelineCard: ObservableObject {
    var voteHandler: (String) -> Void
    
    init(voteHandler: @escaping (String) -> Void) {
        self.voteHandler = voteHandler
    }
}
