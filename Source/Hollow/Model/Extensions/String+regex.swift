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
    
    func range(matches regexString: String) -> [Range<String.Index>] {
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
    
    func matches(regexString: String) -> [String] {
        let range = self.range(matches: regexString)
        return matches(range: range)
    }
    
    func matches(range: [Range<String.Index>]) -> [String] {
        return range.map({ String(self[$0]) })
    }
    
    func links() -> [String] {
        return self.matches(range: rangeForLink())
    }
    
    func citations() -> [String] {
        return self.matches(range: rangeForCitation())
    }
    
    func citationNumbers() -> [Int] {
        return self.citations()
            .compactMap({ Int(String($0.dropFirst())) })
            .dropDuplicates()
            .sorted(by: { $0 < $1 })
    }
    
    func rangeForLink() -> [Range<String.Index>] {
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
}
