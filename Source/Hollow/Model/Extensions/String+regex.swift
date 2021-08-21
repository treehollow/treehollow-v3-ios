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
    
    private func range(matches regexString: String) -> [NSRange] {
        do {
            let regex = try NSRegularExpression(pattern: regexString)
            let str = self.str()
            let results = regex.matches(in: str, range: NSRange(self.startIndex..., in: str))
            return results.map { $0.range }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    private func matches(regexString: String) -> [String] {
        let range = self.range(matches: regexString)
        return matches(range: range)
    }
    
    private func matches(range: [NSRange]) -> [String] {
        let str = self.str()
        return range
            .compactMap { Range($0, in: str) }
            .map({ String(str[$0]) })
    }
    
    func rangeForLink() -> [NSRange] {
        // Won't scan for long long long long string
        if self.count > 4000 { return [] }
        let str = self.str()
        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try! NSDataDetector(types: types.rawValue)
        let matches = detector.matches(in: str, range: NSRange(str.startIndex..., in: str))
        return matches.map { $0.range }
    }
    
    func rangeForCitation() -> [NSRange] {
        return self.range(matches: #"#\d{1,7}"#)
    }
    
    func links(in ranges: [NSRange]) -> [String] {
        ranges.compactMap {
            guard let range = Range($0, in: self) else { return nil }
            return String(self[range])
        }
    }
    
    func citationNumbers(in ranges: [NSRange]) -> [Int] {
        ranges.compactMap {
            guard let range = Range($0, in: self) else { return nil }
            var string = String(self[range])
            string.removeFirst()
            return Int(string)
        }

    }
    
    @available (iOS 15.0, *)
    func attributedForCitationAndLink(citationsRanges: [NSRange], linkRanges: [NSRange]) -> AttributedString {
        // Directly generating attributed string from `self` will result
        // in incorrect ranges, and the reason is a mystery.
        let str = str()
        var attrStr = AttributedString(str)
        
        let rangeForLink = linkRanges.compactMap { Range($0, in: str) }
        let rangeForCitation = citationsRanges.compactMap { Range($0, in: str) }
        
        let links = rangeForLink.map { range in
            // Handle the url on our own based on the open-url settings
            (AttributedString.Index(range.lowerBound, within: attrStr)!..<AttributedString.Index(range.upperBound, within: attrStr)!, URL(string: String("Hollow://url-" + str[range])))
        }
        let citations = rangeForCitation.map({ range in
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
    
    @available (iOS 15.0, *)
    func attributedForCitationAndLink() -> AttributedString {
        let str = self.str()

        let citationRanges = str.rangeForCitation()
        let linkRanges = str.rangeForLink()
        
        return attributedForCitationAndLink(citationsRanges: citationRanges, linkRanges: linkRanges)
    }

    private func str() -> String {
        let data = self.data(using: .utf8)!
        return String(data: data, encoding: .utf8)!
    }
}
