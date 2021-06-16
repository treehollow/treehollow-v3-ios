//
//  String+regex.swift
//  Hollow
//
//  Created by aliceinhollow on 12/2/2021.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

extension String {
    /// find CitedPostID from a post text
    /// - Returns: Pid Int?
    func findCitedPostID() -> Int? {
        let pidStrings = self.matches(regexString: #"#\d{1,7}"#)
        if pidStrings.count == 1 {
            // Exactly one cited post
            let postIdString = String(pidStrings[0].dropFirst())
            return Int(postIdString)
        } else {
            return nil
        }
    }
    
    private func range(matches regexString: String) -> [Range<String.Index>] {
        do {
            let regex = try NSRegularExpression(pattern: regexString)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return results.compactMap {
                Range($0.range, in: self)
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    private func matches(regexString: String) -> [String] {
        let range = self.range(matches: regexString)
        return matches(range: range)
    }
    
    private func matches(range: [Range<String.Index>]) -> [String] {
        return range.map({ String(self[$0]) })
    }
    
    func links() -> [String] {
        return self.matches(range: rangeForLink())
    }
    
    func citations() -> [String] {
        return self.matches(range: rangeForCitation())
    }
    
    func citationNumbers() -> [Int] {
        // Won't scan for long long long long string
        if self.count > 4000 { return [] }

        return self.citations()
            .compactMap({ Int(String($0.dropFirst())) })
            .dropDuplicates()
            .sorted(by: { $0 < $1 })
    }
    
    func rangeForLink() -> [Range<String.Index>] {
        // Won't scan for long long long long string
        if self.count > 4000 { return [] }
        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try! NSDataDetector(types: types.rawValue)
        let matches = detector.matches(in: self, range: NSRange(self.startIndex..., in: self))
        return matches.compactMap {
            Range($0.range, in: self)
        }
    }
    
    func rangeForCitation() -> [Range<String.Index>] {
        return self.range(matches: #"#\d{1,7}"#)
    }
    
    func attributedForCitationAndLink() -> AttributedString {
        // Directly generating attributed string from `self` will result
        // in incorrect ranges, and the reason is a mystery.
        let data = self.data(using: .utf8)!
        let str = String(data: data, encoding: .utf8)!
        var attrStr = AttributedString(str)
        let links = str.rangeForLink().map { range in
            (AttributedString.Index(range.lowerBound, within: attrStr)!..<AttributedString.Index(range.upperBound, within: attrStr)!, URL(string: String(str[range])))
        }
        let citations = str.rangeForCitation().map({ range in
            (AttributedString.Index(range.lowerBound, within: attrStr)!..<AttributedString.Index(range.upperBound, within: attrStr)!, URL(string: "Hollow://post-\(String(str[range]))"))
        })
        
        for range in links {
            attrStr[range.0].link = range.1
        }
        for range in citations {
            attrStr[range.0].link = range.1
        }
        return attrStr
    }
}
