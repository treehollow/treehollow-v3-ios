//
//  DateExtensions.swift
//  Hollow
//
//  Created by 梁业升 on 2021/2/28.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

extension Date {
    var startOfDay: Date {
        return Calendar(identifier: .iso8601).startOfDay(for: self)
    }
    
    var endOfDay: Date {
        let nextDay = self + 24 * 60 * 60
        return Calendar(identifier: .iso8601).startOfDay(for: nextDay) - 60
    }
}
