//
//  SendVoteRequest.swift
//  Hollow
//
//  Created on 2021/1/18.
//

import HollowCore

struct SendVoteRequest: DefaultConfigurationRequestAdaptor {
    typealias R = HollowCore.SendVoteRequest
    
    typealias Configuration = HollowCore.SendVoteRequest.Configuration
    
    typealias FinalResult = VoteData?
    
    var configuration: Configuration
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    func transformResult(_ result: Vote) -> VoteData? {
        return result.toVoteData()
    }
}
