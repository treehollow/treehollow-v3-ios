//
//  ImageTitledStack.swift
//  Hollow
//
//  Created by liang2kl on 2021/4/28.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct ImageTitledStack<Content: View>: View {
    let alignment: HorizontalAlignment
    let spacing: CGFloat?
    let systemImageName: String
    let content: () -> Content
    
    init(alignment: HorizontalAlignment = .leading, spacing: CGFloat? = nil, systemImageName: String, @ViewBuilder content: @escaping () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.systemImageName = systemImageName
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            Text(Image(systemName: systemImageName))
                .fontWeight(.semibold)
                .foregroundColor(.tint)
                .font(.largeTitle)
                .padding(.bottom)
            content()
                .lineSpacing(5)
        }
    }
}
