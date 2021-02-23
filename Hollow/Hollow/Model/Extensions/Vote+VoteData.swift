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
