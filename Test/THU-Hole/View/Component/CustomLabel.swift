//
//  CustomLabel.swift
//  THU-Hole
//
//  Created by 梁业升 on 2021/1/13.
//

import SwiftUI

struct CustomLabel: View {
    var title: String
    var systemImageName: String
    var spacing: CGFloat? = nil
    var body: some View {
        HStack(spacing: spacing) {
            Image(systemName: systemImageName)
            Text(title)
        }
    }
}
