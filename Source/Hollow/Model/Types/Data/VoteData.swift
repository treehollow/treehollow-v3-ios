//
//  VoteData.swift
//  Hollow
//
//  Created by aliceinhollow on 11/2/2021.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import HollowCore

/// Vote Data Type
struct VoteData: Codable {
    /// The option that the current user selected, `nil` if not voted.
    var votedOption: String?
    var voteData: [Data]
    struct Data: Identifiable, Codable {
        // Identifiable
        var id: String { self.title }
        
        var title: String
        var voteCount: Int
    }
}

extension Vote {
    func toVoteData() -> VoteData? {
        guard let voteOptions = self.voteOptions, let vote = self.voteData, let voted = self.voted else {
            return nil
        }
        var voteData = [VoteData.Data]()
        for voteOption in voteOptions {
            guard let voteNumber = vote[voteOption] else { continue }
            voteData.append(VoteData.Data(title: voteOption, voteCount: voteNumber))
        }
        return VoteData(votedOption: voted, voteData: voteData)
    }
}
