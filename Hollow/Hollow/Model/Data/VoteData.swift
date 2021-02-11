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
    var voted: Bool
    /// The option that the current user selected, `nil` if not voted.
    var votedOption: String?
    var voteData: [VoteData]
    struct VoteData: Identifiable {
        // Identifiable
        var id: String { self.title }
        
        var title: String
        var voteCount: Int
    }
}


/// convert Vote to VoteData
/// - Parameter voteResult: Vote for converting
/// - Returns: VoteData
func initVoteDataByVote(voteResult: Vote) -> VoteData {
    var voteData = [VoteData.VoteData]()
    for (voteOption, voteNum) in voteResult.voteData {
        voteData.append(VoteData.VoteData(title: voteOption, voteCount: voteNum))
    }
    return VoteData(voted: (voteResult.voted != ""), votedOption: voteResult.voted, voteData: voteData)
}
