//
//  Text+plain.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

extension Text {
    func hollowContent() -> some View {
        return self.font(.dynamic(size: 16)).lineSpacing(3)
    }
    
    func hollowComment() -> some View {
        return self.font(.dynamic(size: 15)).lineSpacing(3)
    }
    
    func hollowPostId() -> some View {
        return self.font(.dynamic(size: 15)).lineSpacing(3)
    }
    
    func hollowPostTime() -> some View {
        return self.font(.dynamic(size: 13)).lineSpacing(2.5)
    }
    
    func mainTabText(selected: Bool) -> some View {
        return self
            .fontWeight(.heavy)
            .font(.dynamic(size: selected ? 22 : 18))
            .foregroundColor(selected ? .mainPageSelected : .mainPageUnselected)
            .lineLimit(1)
    }
}
