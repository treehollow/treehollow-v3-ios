//
//  HollowTimelineCardView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct HollowTimelineCardView: View {
    @Binding var postDataWrapper: PostDataWrapper
    @ObservedObject var viewModel: HollowTimelineCard
    
    var body: some View {
        VStack(spacing: 15) {
            // TODO: Star actions
            HollowHeaderView(postData: $postDataWrapper.post, compact: false)
            HollowContentView(postDataWrapper: $postDataWrapper, compact: true, voteHandler: viewModel.voteHandler)
            // Check if comments exist to avoid additional spacing
            if postDataWrapper.post.comments.count > 0 {
                CommentView(comments: $postDataWrapper.post.comments)
            }
        }
        .padding()
        .background(Color.hollowCardBackground)
        .cornerRadius(10)
        .fixedSize(horizontal: false, vertical: true)
        .contentShape(RoundedRectangle(cornerRadius: 8))
        .contextMenu(ContextMenu(menuItems: {
            HollowHeaderMenu()
        }))
    }
    
    private struct CommentView: View {
        @Binding var comments: [CommentData]
        /// Max comments to be displayed in the timeline card.
        @State private var maxCommentCount = 3
        
        @ScaledMetric(wrappedValue: 15, relativeTo: .body) var body15: CGFloat
        
        var body: some View {
            VStack(spacing: 0) {
                ForEach(comments.prefix(maxCommentCount).indices, id: \.self) { index in
                    HollowCommentContentView(commentData: $comments[index], compact: true, contentVerticalPadding: 10)
                }
                if comments.count > maxCommentCount {
                    // FIXME: How to localize this stuff??
                    Text("还有 \(comments.count - maxCommentCount) 条评论")
                        .font(.system(size: body15)).lineSpacing(3)

                    .foregroundColor(.uiColor(.secondaryLabel))
                    .padding(.top)
                }
            }
        }
    }
}

struct HollowTimelineCardView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            HollowTimelineCardView(postDataWrapper: .constant(testPostWrappers[1]), viewModel: .init(voteHandler: {string in print(string)}))
                .padding()
                .background(Color.background)
            HollowTimelineCardView(postDataWrapper: .constant(testPostWrappers[1]), viewModel: .init(voteHandler: {string in print(string)}))
                .padding()
                .background(Color.background)
                .colorScheme(.dark)
        }
    }
}

