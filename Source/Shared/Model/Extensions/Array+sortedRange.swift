//
//  Array+sortedRange.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/6.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

extension Array where Element == Range<String.Index> {
    func sortedByRange() -> Self {
        guard self.count > 0 else { return self }
        var newRanges = self.sorted(by: { $0.lowerBound <= $1.lowerBound })
        for index in 0..<newRanges.count - 1 {
            let firstLower = newRanges[index].lowerBound
            let firstUpper = newRanges[index].upperBound
            let secondLower = newRanges[index + 1].lowerBound
            let secondUpper = newRanges[index + 1].upperBound
            newRanges[index] = .init(uncheckedBounds: (firstLower, Swift.min(firstUpper, secondLower)))
            newRanges[index + 1] = .init(uncheckedBounds: (secondLower, Swift.max(firstUpper, secondUpper)))
        }
        return newRanges
    }
    
    mutating func sortByRange() {
        self = self.sortedByRange()
    }
}
