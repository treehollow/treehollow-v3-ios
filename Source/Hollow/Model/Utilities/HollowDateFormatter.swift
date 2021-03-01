//
//  HollowDateFormatter.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Combine

struct HollowDateFormatter {
    var date: Date
    
    func formattedString(compact: Bool = false) -> String {
        let currentDate = Date()
        let timeInterval = currentDate.timeIntervalSince(date)
        if timeInterval < 60 {
            return NSLocalizedString("DATEFORMATTER_LESS_THAN_A_MINUTE", comment: "")
        }
        if timeInterval < 3600 {
            let value = Int(timeInterval) / 60
            return value.string + NSLocalizedString("DATEFORMATTER_MINUTE", comment: "")
        }
        if timeInterval < 24 * 3600 {
            let value = Int(timeInterval) / 3600
            return value.string + NSLocalizedString("DATEFORMATTER_HOUR", comment: "")
        }
        
        let formatter = DateFormatter()
        let thisYear = Calendar.current.component(.year, from: currentDate)
        let postYear = Calendar.current.component(.year, from: date)
        if thisYear == postYear {
            let format = compact ? "MM-dd" : "MM-dd hh:mm"
            formatter.dateFormat = format
        } else {
            let format = compact ? "yy-MM-dd" : "yy-MM-dd hh:mm"
            formatter.dateFormat = format
        }
        var string = formatter.string(from: date)
        if string.first == "0" { string.removeFirst() }
        return string
    }
    
}

extension HollowDateFormatter {
    static func publisher(for date: Date) -> AnyPublisher<String, Never> {
        return Timer.timeChangePublisher
            .map({ _ in HollowDateFormatter(date: date).formattedString() })
            .eraseToAnyPublisher()
    }
}
