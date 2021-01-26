//
//  HollowTimelineCard.swift
//  Hollow
//
//  Created by 梁业升 on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Combine

class HollowTimelineCard: ObservableObject {
    var voteHandler: (String) -> Void
    
    init(voteHandler: @escaping (String) -> Void) {
        self.voteHandler = voteHandler
    }
}
