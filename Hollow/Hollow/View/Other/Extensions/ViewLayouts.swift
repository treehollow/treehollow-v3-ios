//
//  View+layout.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/20.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func leading() -> some View {
        return HStack(spacing: 0) {
            self
            Spacer()
        }
    }
    
    func fixedSizedLeading() -> some View {
        return self.leading().fixedSize()
    }
    
    func top() -> some View {
        return VStack(spacing: 0) {
            self
            Spacer()
        }
    }
    
    func fixedSizedTop() -> some View {
        return self.top().fixedSize()
    }
    
    func horizontalCenter() -> some View {
        return HStack(spacing: 0) {
            Spacer()
            self
            Spacer()
        }
    }
    
    func trailing() -> some View {
        return HStack(spacing: 0) {
            Spacer()
            self
        }
    }
}
