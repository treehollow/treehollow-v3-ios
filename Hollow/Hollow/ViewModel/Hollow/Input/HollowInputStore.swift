//
//  HollowInputStore.swift
//  Hollow
//
//  Created by liang2kls on 2021/2/11.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import Defaults

class HollowInputStore: ObservableObject {
    @Published var text: String = ""
    // FIXME: Remove this code in real tests
    #if targetEnvironment(simulator)
    @Published var availableTags: [String] = ["性相关", "政治相关", "令人不适"]
    #else
    @Published var availableTags: [String] = Defaults[.hollowConfig]!.sendableTags
    #endif
    @Published var selectedTag: String?
    @Published var voteInformation: VoteInformation?
    
}

extension HollowInputStore {
    struct VoteInformation {
        var options: [String]
        var hasDuplicate: Bool { Set(options).count != options.count }
    }
}
