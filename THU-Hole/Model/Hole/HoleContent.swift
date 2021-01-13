//
//  CardContent.swift
//  THU-Hole
//
//  Created by 梁业升 on 2021/1/13.
//

import SwiftUI

enum HoleContentType {
    // TODO: Add more types
    case h1, h2, h3, h4, plain, bold, italic, ul, ol(_ index: Int)
}

extension Text {
    func textAttribute(type: HoleContentType) -> Text {
        switch type {
        case .h1:
            return self.bold().font(.title)
        case .h2:
            if #available(iOS 14.0, *) {
                return self.bold().font(.title2)
            } else {
                return self.font(.system(size: 22, weight: .bold))
            }
        case .h3:
            if #available(iOS 14.0, *) {
                return self.bold().font(.title3)
            } else {
                return self.font(.system(size: 20, weight: .bold))
            }
        case .h4: return self.bold().font(.system(size: 18))
        case .plain: return self
        case .bold: return self.bold()
        case .italic: return self.italic()
        case .ul: return Text("  • ") + self
        case .ol(let index): return Text("\(index). ") + self
        }
    }
}
