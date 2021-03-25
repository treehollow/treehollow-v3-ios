//
//  Text+highlight.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/6.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension Text {
    static private func highlight(_ string: String, matchedRange ranges: [Range<String.Index>], modifiers: @escaping (Text) -> Text) -> Text {
        if string == "" || ranges.isEmpty { return Text(string) }
        var text = Text("")
        var position = string.startIndex
        let newRanges = ranges.sortedByRange()
        for range in newRanges {
            let subString1 = string[position..<range.lowerBound]
            let subString2 = string[range.lowerBound..<range.upperBound]
            text = text + Text(subString1)
            text = text + modifiers(Text(subString2))
            position = range.upperBound
        }
        text = text + Text(string[position...])
        return text
    }
    
    static func highlightLinksAndCitation(_ string: String, modifiers: @escaping (Text) -> Text) -> Text {
        let range = string.rangeForLink() + string.rangeForCitation()
        return highlight(string, matchedRange: range, modifiers: modifiers)
    }
}
