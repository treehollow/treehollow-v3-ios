//
//  HoleCommentHeaderView.swift
//  THU-Hole
//
//  Created by 梁业升 on 2021/1/13.
//

import SwiftUI

struct HoleCommentHeaderView: View {
    var configuration: HoleCommentHeaderConfiguration
    var body: some View {
        VStack {
            HStack {
                Text("#\(configuration.holeIndex)")
                    .headerSecondaryBoldText()
                    .foregroundColor(.gray)
                    .layoutPriority(100)
                Text(configuration.timeString)
                    .headerSecondaryText()
                    .foregroundColor(.gray)
                Spacer()
                if !configuration.compact {
                    Button(action: {
                        // TODO: add report action here
                    }, label: {
                        HStack(spacing: 2) {
                            Image(systemName: "flag.fill")
                            Text("举报")
                        }
                        .animation(.spring())
                        .font(.footnote)
                        .foregroundColor(.red)
                    })
                    .animation(.none)
                    .layoutPriority(90)
                }
            }
        }
    }
}

struct HoleCommentHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HoleCommentHeaderView(configuration: .init(holeIndex: 893865, timeString: "2天之前 1-11 21:41:33", compact: true))
        HoleCommentHeaderView(configuration: .init(holeIndex: 893865, timeString: "2天之前 1-11 21:41:33", compact: false))
    }
}
