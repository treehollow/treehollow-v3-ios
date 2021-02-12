//
//  String+CitedPostID.swift
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
        let pidstrings = self.matches(regexString: #"#\d{1,7}"#)
        if !pidstrings.isEmpty {
            return Int(pidstrings[0])
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
