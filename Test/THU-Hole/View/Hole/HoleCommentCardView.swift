//
//  HoleCommentCardView.swift
//  THU-Hole
//
//  Created by 梁业升 on 2021/1/13.
//

import SwiftUI

struct HoleCommentCardView: View {
    var configuration: HoleCommentConfiguration
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HoleCommentHeaderView(configuration: configuration.headerConfiguration)
                .padding(.bottom, 5)
            HoleContentView(texts: configuration.texts)
        }
        .card()

        // long press actions
        .contextMenu(menuItems: {
            // TODO: Check if it has starred
            Button(action: {
                // action for star of unstar
            }) {
                CustomLabel(title: "收藏", systemImageName: "star")
            }
            
            // TODO: add more actions
        })
    }
}

struct HoleCommentView_Previews: PreviewProvider {
    static let testText: [Text] = [
        Text("支持！")
    ]
    static var previews: some View {
        HoleCommentCardView(configuration: .init(headerConfiguration: .init(holeIndex: 881840, timeString: "2天之前 1-11 21:41:33", compact: true), texts: testText))
    }
}
