//
//  VoteData.swift
//  Hollow
//
//  Created by aliceinhollow on 11/2/2021.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

/// Vote Data Type
struct VoteData {
    /// The option that the current user selected, `nil` if not voted.
    var votedOption: String?
    var voteData: [Data]
    struct Data: Identifiable {
        // Identifiable
        var id: String { self.title }
        
        var title: String
        var voteCount: Int
    }
}
