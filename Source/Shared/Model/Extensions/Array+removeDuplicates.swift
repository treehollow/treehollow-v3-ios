//
//  Array+removeDuplicates.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/6.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

extension Array where Element : Hashable {
    func dropDuplicates() -> Self {
        return Array(Set(self))
    }
    
    mutating func removeDuplicates() {
        self = self.dropDuplicates()
    }
}
