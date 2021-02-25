//
//  HollowWanderCardView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct HollowWanderCardView: View {
    @Binding var postData: PostData
    
    @ScaledMetric(wrappedValue: 5, relativeTo: .body) var body5: CGFloat

    var body: some View {
        // FIXME: Handlers
        VStack {
            HollowHeaderView(postData: postData, compact: true)
                .padding(.bottom, body5)
            VStack {
                HollowContentView(
                    postDataWrapper: .init(post: postData, citedPost: nil),
                    options: [.displayVote, .disableVote, .displayImage, .replaceForImageOnly, .compactText],
                    voteHandler: { _ in },
                    lineLimit: 20
                )
            }
            // TODO: Vote and cite
            HStack {
                Label("\(postData.replyNumber)", systemImage: "quote.bubble")
                    .foregroundColor(.hollowCardStarUnselected)
                Spacer()
                Label("\(postData.likeNumber)", systemImage: postData.attention ? "star.fill" : "star")
                    .foregroundColor(postData.attention ? .hollowCardStarSelected : .hollowCardStarUnselected)
            }
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .padding(.top, body5)
            .padding(.horizontal, 5)
        }
        .padding()
        .background(Color.hollowCardBackground)
        .cornerRadius(20)
    }
}
