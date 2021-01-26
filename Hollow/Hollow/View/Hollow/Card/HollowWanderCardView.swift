//
//  HollowWanderCardView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct HollowWanderCardView: View {
    @Binding var postData: PostData
    var body: some View {
        // FIXME: Handlers
        VStack {
            HollowHeaderView(viewModel: .init(starHandler: {_ in }), postData: $postData, compact: true)
            HollowTextView(text: $postData.text, compactLineLimit: 20)
            // TODO: Vote and cite
            HStack {
                HollowStarButton(attention: $postData.attention, likeNumber: $postData.likeNumber, starHandler: {_ in})
                    .padding(.leading, 10)
                Spacer()
                HollowButton(number: .constant(postData.comments.count), action: {
                    // Show detail
                }, systemImageName: "quote.bubble")
                .foregroundColor(.hollowContentText)
                .padding(.trailing, 10)
            }
            .padding(.top, 5)
        }
        .padding()
        .background(Color.hollowCardBackground)
        .cornerRadius(20)
    }
}

struct HollowWanderCardView_Previews: PreviewProvider {
    static var previews: some View {
        HollowWanderCardView(postData: .constant(testPostData)).frame(width: 200).padding().background(Color.background)
    }
}
