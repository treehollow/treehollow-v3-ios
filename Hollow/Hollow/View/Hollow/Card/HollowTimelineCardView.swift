//
//  HollowTimelineCardView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI
import Defaults

struct HollowTimelineCardView: View {
    @Binding var postDataWrapper: PostDataWrapper
    @ObservedObject var viewModel: HollowTimelineCard
    
    private let foldTags = Defaults[.hollowConfig]?.foldTags ?? []
    private var hideComments: Bool {
        if let tag = postDataWrapper.post.tag {
            return foldTags.contains(tag)
        }
        return false
    }
    
    var body: some View {
        VStack(spacing: 15) {
            // TODO: Star actions
            HollowHeaderView(postData: postDataWrapper.post, compact: false)
            HollowContentView(
                postDataWrapper: postDataWrapper,
                options: [.compactText, .displayCitedPost, .displayImage, .displayVote],
                voteHandler: viewModel.voteHandler
            )
            // Check if comments exist to avoid additional spacing
            if postDataWrapper.post.comments.count > 0, !hideComments {
                CommentView(postData: $postDataWrapper.post)
            }
        }
        .padding()
        .background(Color.hollowCardBackground)
        .cornerRadius(10)
        .fixedSize(horizontal: false, vertical: true)
        .contentShape(RoundedRectangle(cornerRadius: 8))
        .contextMenu(ContextMenu(menuItems: {
            Section {
                Button(action: {

                }) {
                    Label("TIMELINE_CARD_MENU_REPORT", systemImage: "exclamationmark")
                }
            }
        }))
    }
    
    private struct CommentView: View {
        @Binding var postData: PostData
        /// Max comments to be displayed in the timeline card.
        @State private var maxCommentCount = 3
        
        @ScaledMetric(wrappedValue: 15, relativeTo: .body) var body15: CGFloat
        
        var body: some View {
            VStack(spacing: 0) {
                ForEach(postData.comments.indices.prefix(maxCommentCount), id: \.self) { index in
                    HollowCommentContentView(commentData: $postData.comments[index], compact: true, contentVerticalPadding: 10)
                }
                if postData.replyNumber > maxCommentCount {
                    // Localize the text based on chinese expression
                    let text1 = NSLocalizedString("TIMELINE_CARD_COMMENTS_HAIYOU", comment: "")
                    let text2 = NSLocalizedString("TIMELINE_CARD_COMMENTS_TIAOPINGLUN", comment: "")
                    Text(text1 + "\(postData.replyNumber - maxCommentCount)" + text2)
                        .font(.system(size: body15)).lineSpacing(3)

                    .foregroundColor(.uiColor(.secondaryLabel))
                    .padding(.top)
                }
            }
        }
    }
}
