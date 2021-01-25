//
//  Text+plain.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

extension Text {
    func hollowContent() -> some View {
        return self.font(.system(size: 16)).lineSpacing(3)
    }
    
    func hollowComment() -> some View {
        return self.font(.system(size: 15)).lineSpacing(3)
    }
    
    func hollowPostId() -> some View {
        return self.font(.system(size: 15)).lineSpacing(3)
    }
    
    func hollowPostTime() -> some View {
        return self.font(.system(size: 13)).lineSpacing(2.5)
    }
    
    func mainTabText(selected: Bool) -> some View {
        return self
            .fontWeight(.heavy)
            .font(.system(size: selected ? 20 : 16))
            .foregroundColor(selected ? .mainPageSelected : .mainPageUnselected)
    }
}
