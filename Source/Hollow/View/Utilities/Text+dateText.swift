//
//  Text+dateText.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension Text {
    static func dateText(_ date: Date, compact: Bool = false) -> Text {
        let dateString = HollowDateFormatter(date: date).formattedString(compact: compact)
        return Text(dateString)
    }
}
