//
//  String+findCitedPostID.swift
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
    
    func matches(regexString: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regexString)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }

}
