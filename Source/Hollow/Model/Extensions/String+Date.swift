//
//  String+Date.swift
//  Hollow
//
//  Created by aliceinhollow on 7/2/2021.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

extension String {
    func toDate() -> Date? {
        let dateAsString = self
        let dateFormatter = DateFormatter()
        // 1926-08-17
        dateFormatter.dateFormat = "yyyy-MM-dd"
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+00:00")
        let date = dateFormatter.date(from: dateAsString)
        return date
    }
}
