//
//  PostListView.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

struct PostListView: View {
    @Binding var postDataWrappers: [PostDataWrapper]
    @Binding var detailStore: HollowDetailStore?
    @Default(.blockedTags) var customBlockedTags
    @Default(.foldPredefinedTags) var foldPredefinedTags
    
    var revealFoldedTags = false
    var contentViewDisplayOptions: HollowContentView.DisplayOptions {
        var options: HollowContentView.DisplayOptions = [
            .compactText, .displayCitedPost, .displayImage, .displayVote
        ]
        if revealFoldedTags { options.insert(.revealFoldTags) }
        return options
    }
    var voteHandler: (Int, String) -> Void
    var starHandler: (Bool, Int) -> Void
    private let foldTags = Defaults[.hollowConfig]?.foldTags ?? []
    
    private func hideComments(for post: PostData) -> Bool {
        if revealFoldedTags { return false }
        if let tag = post.tag {
            if !foldPredefinedTags {
                return customBlockedTags.contains(tag)
            }
            return foldTags.contains(tag) || customBlockedTags.contains(tag)
        }
        return false
    }
    
    var body: some View {
        ForEach(postDataWrappers) { postDataWrapper in
            let post = postDataWrapper.post
            VStack(spacing: 15) {
                // TODO: Star actions
                HollowHeaderView(postData: post, compact: false, starAction: { starHandler($0, post.postId) }, disableAttention: false)
                HollowContentView(
                    postDataWrapper: postDataWrapper,
                    options: contentViewDisplayOptions,
                    voteHandler: { option in voteHandler(post.postId, option) }
                )
                // Check if comments exist to avoid additional spacing
                if post.replyNumber > 0, !hideComments(for: post) {
                    VStack(spacing: 0) {
                        ForEach(post.comments.prefix(3)) { commentData in
                            HollowCommentContentView(commentData: .constant(commentData), compact: true, contentVerticalPadding: 10, postColorIndex: 0, postHash: 0)
                        }
                        let shownReplyNumber = min(postDataWrapper.post.comments.count, 3)
                        if post.replyNumber > shownReplyNumber {
                            if post.comments.count == 0 {
                                Divider()
                                    .padding(.horizontal)
                            }
                            // Localize the text based on chinese expression
                            let text1 = NSLocalizedString("TIMELINE_CARD_COMMENTS_HAIYOU", comment: "")
                            let text2 = NSLocalizedString("TIMELINE_CARD_COMMENTS_TIAOPINGLUN", comment: "")
                            Text(text1 + "\(post.replyNumber - shownReplyNumber)" + text2)
                                .dynamicFont(size: 15).lineSpacing(post.comments.count == 0 ? 0 : 3)
                                
                                .foregroundColor(.uiColor(.secondaryLabel))
                                .padding(.top)
                        }
                    }
                }
            }
            .padding()
            .background(Color.hollowCardBackground)
            .roundedCorner(13)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom)
            .onTapGesture {
                guard let index = postDataWrappers.firstIndex(where: { $0.id == postDataWrapper.id }) else { return }
                presentView {
                    HollowDetailView(store: HollowDetailStore(bindingPostWrapper: $postDataWrappers[index]))
                }
            }
        }

    }
}
