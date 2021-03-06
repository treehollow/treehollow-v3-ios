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
        var newRanges = self.sorted(by: { $0.lowerBound <= $1.lowerBound })
        for index in 0..<newRanges.count-1 {
            if newRanges[index].upperBound >= newRanges[index + 1].lowerBound {
                if newRanges[index].upperBound > newRanges[index + 1].upperBound {
                    newRanges[index] = .init(uncheckedBounds: (newRanges[index].lowerBound, newRanges[index + 1].lowerBound))
                    newRanges[index + 1] = .init(uncheckedBounds: (newRanges[index + 1].lowerBound, newRanges[index].upperBound))
                } else {
                    newRanges[index] = .init(uncheckedBounds: (newRanges[index].lowerBound, newRanges[index + 1].lowerBound))
                }
            }
        }
        return newRanges
    }
    
    mutating func sortByRange() {
        self = self.sortedByRange()
    }
}
