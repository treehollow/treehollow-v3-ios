//
//  HollowTimelineCardView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct HollowTimelineCardView: View {
    @Binding var postData: PostData
    @ObservedObject var viewModel: HollowTimelineCard
    
    private let verticalSpacing: CGFloat = 10
    
    var body: some View {
        VStack(spacing: 15) {
            // TODO: Star actions
            HollowHeaderView(viewModel: .init(starHandler: {_ in}), postData: $postData, compact: false)
            HollowContentView(postData: $postData, compact: true, voteHandler: viewModel.voteHandler)
            // Check if comments exist to avoid additional spacing
            if postData.comments.count > 0 {
                CommentView(comments: $postData.comments)
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
        var body: some View {
            VStack(spacing: 0) {
                // The comment number might change if auto update, so use Identifiable protocol on `CommentData`.
                ForEach(comments.prefix(maxCommentCount)) { comment in
                    HollowCommentContentView(commentData: .constant(comment), compact: true, contentVerticalPadding: 10)
                }
                if comments.count > maxCommentCount {
                    // FIXME: How to localize this stuff??
                    Button(action:{
                        withAnimation {
                            maxCommentCount += 10
                        }
                    }) {
                        HStack {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 15))
                            Text("还有 \(comments.count - maxCommentCount) 条评论")
                                .hollowComment()
                        }
                        .foregroundColor(.uiColor(.secondaryLabel))
                        .padding(.top)
                    }
                }
            }
        }
    }
}

struct HollowTimelineCardView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            HollowTimelineCardView(postData: .constant(testPosts[0]), viewModel: .init(voteHandler: {string in print(string)}))
                .padding()
                .background(Color.background)
            HollowTimelineCardView(postData: .constant(testPosts[1]), viewModel: .init(voteHandler: {string in print(string)}))
                .padding()
                .background(Color.background)
                .colorScheme(.dark)
        }
    }
}

