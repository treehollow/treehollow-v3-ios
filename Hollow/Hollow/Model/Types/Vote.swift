//
//  Vote.swift
//  Hollow
//
//  Created by aliceinhollow on 2/19/21.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

/// Vote for result
struct Vote: Codable {
    var voted: String?
    var voteData: [String: Int]?
}
