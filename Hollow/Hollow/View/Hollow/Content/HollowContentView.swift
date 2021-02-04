//
//  HollowContentView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct HollowContentView: View {
    @Binding var postDataWrapper: PostDataWrapper
    var compact: Bool
    // It should be in the view model, but for convenience we just put here
    var voteHandler: (String) -> Void
    var body: some View {
        if (postDataWrapper.post.type == .image || postDataWrapper.post.type == .vote) && postDataWrapper.post.hollowImage != nil {
            HollowImageView(hollowImage: $postDataWrapper.post.hollowImage)
                .cornerRadius(4)
                .frame(maxHeight: 500)
                .fixedSize(horizontal: false, vertical: true)
        }
        
        if let citedPost = postDataWrapper.citedPost {
            HollowCiteContentView(postData: citedPost)
        }

        HollowTextView(text: $postDataWrapper.post.text, compactLineLimit: compact ? 6 : nil)
                
        if postDataWrapper.post.type == .vote {
            HollowVoteContentView(vote: Binding($postDataWrapper.post.vote)!, viewModel: .init(voteHandler: voteHandler))
        }

    }
}

#if DEBUG
struct HollowContentView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            ForEach(testPostWrappers) { postDataWrapper in
                HollowContentView(postDataWrapper: .constant(postDataWrapper), compact: false, voteHandler: {_ in})
                    .background(Color.background)
            }
        }
    }
}
#endif
