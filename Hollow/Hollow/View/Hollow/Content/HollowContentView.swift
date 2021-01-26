//
//  HollowContentView.swift
//  Hollow
//
//  Created by 梁业升 on 2021/1/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct HollowContentView: View {
    @Binding var postData: PostData
    var compact: Bool
    // It should be in the view model, but for convenience we just put here
    var voteHandler: (String) -> Void
    var body: some View {
        if (postData.type == .image || postData.type == .vote) && postData.hollowImage != nil {
            HollowImageView(hollowImage: $postData.hollowImage)
                .cornerRadius(4)
                .frame(maxHeight: 500)
                .fixedSize(horizontal: false, vertical: true)
        }
        
        HollowTextView(text: $postData.text, compactLineLimit: compact ? 6 : nil)
        
        if postData.type == .vote {
            HollowVoteContentView(vote: Binding($postData.vote)!, viewModel: .init(voteHandler: voteHandler))
        }
    }
}

#if DEBUG
struct HollowContentView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            ForEach(testPosts) { postData in
                HollowContentView(postData: .constant(postData), compact: false, voteHandler: {_ in})
                    .background(Color.background)
            }
        }
    }
}
#endif
