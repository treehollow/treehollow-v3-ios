//
//  CGFloat+dynamic.swift
//  Hollow
//
//  Created by 梁业升 on 2021/2/5.
//  Copyright © 2021 treehollow. All rights reserved.
//

import UIKit

extension CGFloat {
    /// Dynamic font size for the value.
    var dynamic: CGFloat {
        UIFontMetrics.default.scaledValue(for: self)
    }
}

extension Int {
    /// Dynamic font size for the value.
    var dynamic: CGFloat {
        UIFontMetrics.default.scaledValue(for: CGFloat(self))
    }
}
