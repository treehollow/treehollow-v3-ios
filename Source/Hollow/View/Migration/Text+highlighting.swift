//
//  Text+highlighting.swift
//  Text+highlighting
//
//  Created by liang2kl on 2021/8/21.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension Text {
    init(highlighting string: String) {
        let rangesForLink = string.rangeForLink()
        let rangesForCitation = string.rangeForCitation()
        let ranges = (rangesForLink + rangesForCitation)
            .compactMap { Range($0, in: string) }
        if string == "" || ranges.isEmpty {
            self.init(string)
        } else {
            var text = Text("")
            var position = string.startIndex
            let newRanges = ranges.sortedByRange()
            for range in newRanges {
                let subString1 = string[position..<range.lowerBound]
                let subString2 = string[range.lowerBound..<range.upperBound]
                text = text + Text(subString1)
                text = text + Text(subString2).foregroundColor(.hollowContentVoteGradient1)
                position = range.upperBound
            }
            text = text + Text(string[position...])
            self.init("\(text)")
        }
    }
}
