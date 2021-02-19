//
//  Vote+VoteData.swift
//  Hollow
//
//  Created by aliceinhollow on 2/19/21.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

extension Vote {
    /// convert Vote to VoteData
    /// - Parameter self: Vote for converting
    /// - Returns: VoteData
    func toVoteData() -> VoteData {
            var voteData = [VoteData.Data]()
            for (voteOption, voteNum) in self.voteData {
                voteData.append(VoteData.Data(title: voteOption, voteCount: voteNum))
            }
            return VoteData(votedOption: self.voted, voteData: voteData)
    }
}
