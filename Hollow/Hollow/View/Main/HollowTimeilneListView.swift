//
//  HollowTimeilneListView.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

struct HollowTimeilneListView: View {
    @Binding var postDataWrappers: [PostDataWrapper]
    @Binding var detailStore: HollowDetailStore?
    @Binding var detailPresentedIndex: Int?
    
    var voteHandler: (Int, String) -> Void
    private let foldTags = Defaults[.hollowConfig]?.foldTags ?? []
    
    private func hideComments(for post: PostData) -> Bool {
        if let tag = post.tag {
            return foldTags.contains(tag)
        }
        return false
    }
    
    @ScaledMetric(wrappedValue: 15, relativeTo: .body) var body15: CGFloat
    
    
    var body: some View {
        ForEach(postDataWrappers) { postDataWrapper in
            VStack(spacing: 15) {
                // TODO: Star actions
                HollowHeaderView(postData: postDataWrapper.post, compact: false)
                HollowContentView(
                    postDataWrapper: postDataWrapper,
                    options: [.compactText, .displayCitedPost, .displayImage, .displayVote],
                    voteHandler: { option in voteHandler(postDataWrapper.post.postId, option) }
                )
                //                    // Check if comments exist to avoid additional spacing
                if postDataWrapper.post.comments.count > 0, !hideComments(for: postDataWrapper.post) {
                    VStack(spacing: 0) {
                        ForEach(postDataWrapper.post.comments.prefix(3)) { commentData in
                            HollowCommentContentView(commentData: .constant(commentData), compact: true, contentVerticalPadding: 10)
                        }
                        if postDataWrapper.post.replyNumber > 3 {
                            // Localize the text based on chinese expression
                            let text1 = NSLocalizedString("TIMELINE_CARD_COMMENTS_HAIYOU", comment: "")
                            let text2 = NSLocalizedString("TIMELINE_CARD_COMMENTS_TIAOPINGLUN", comment: "")
                            Text(text1 + "\(postDataWrapper.post.replyNumber - 3)" + text2)
                                .font(.system(size: body15)).lineSpacing(3)
                                
                                .foregroundColor(.uiColor(.secondaryLabel))
                                .padding(.top)
                        }
                    }
                }
            }
            .padding()
            .background(Color.hollowCardBackground)
            .cornerRadius(10)
            .fixedSize(horizontal: false, vertical: true)
            .contentShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
            .padding(.bottom)
            .onTapGesture {
                guard let index = postDataWrappers.firstIndex(where: { $0.id == postDataWrapper.id }) else { return }
                detailStore = HollowDetailStore(bindingPostWrapper: $postDataWrappers[index])
                DispatchQueue.main.async {
                    detailPresentedIndex = index
                }
            }
            

        }

    }
}
