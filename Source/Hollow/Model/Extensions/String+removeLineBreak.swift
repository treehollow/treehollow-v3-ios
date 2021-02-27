//
//  String+removeLineBreak.swift
//  Hollow
//
//  Created by 梁业升 on 2021/2/8.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

extension String {
    func removeLineBreak(replaceBy seperator: String = " ") -> String {
        let unsafeChars = "\n"
        let cleanChars = self.components(separatedBy: unsafeChars).joined(separator: seperator)
        return cleanChars
    }
}
