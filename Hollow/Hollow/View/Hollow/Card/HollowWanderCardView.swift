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
                HollowStarButton(attention: postData.attention, likeNumber: postData.likeNumber, starHandler: {_ in})
                    .padding(.leading, 10)
                Spacer()
                HollowButton(number: postData.comments.count, action: {
                    // Show detail
                }, systemImageName: "quote.bubble")
                .foregroundColor(.hollowContentText)
                .padding(.trailing, 10)
            }
            .padding(.top, body5)
        }
        .padding()
        .background(Color.hollowCardBackground)
        .cornerRadius(20)
    }
}
