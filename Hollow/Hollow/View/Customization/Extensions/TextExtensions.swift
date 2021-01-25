//
//  Text+plain.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

extension Font {
    static let plain = Font.system(size: 16)
    static let commentPlain = Font.system(size: 14)
}

extension Text {
    func hollowContent() -> some View {
        return self.font(.plain).lineSpacing(3)
    }
    
    func hollowComment() -> some View {
        return self.font(.commentPlain).lineSpacing(3)
    }
}
