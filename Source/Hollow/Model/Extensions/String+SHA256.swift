//
//  StringSHA256.swift
//  Hollow
//
//  Created by aliceinhollow on 3/2/2021.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import CryptoKit

extension String {
    /// calculate sha256
    func sha256() -> String {
        if let stringData = self.data(using: String.Encoding.utf8) {
            let sha256String = SHA256.hash(data: stringData).compactMap {
                String(format: "%02x", $0)
            }.joined()
            return sha256String
        }
        return ""
    }
}
