//
//  HollowDetailView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct HollowDetailView: View {
    @Binding var postDataWrapper: PostDataWrapper
    @Binding var presentedIndex: Int?
    
    @ScaledMetric(wrappedValue: 20, relativeTo: .body) var body20: CGFloat
    @ScaledMetric(wrappedValue: 10) var headerVerticalPadding: CGFloat

    var body: some View {
        // FIXME: Handlers
        ZStack {
            Color.hollowDetailBackground.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 0) {
                    HStack {
                        Button(action:{
                            // Navigate back
                            presentedIndex = nil
                        }) {
                            Image(systemName: "xmark")
                                .imageButton(sizeFor20: body20)
                                .padding(.trailing, 5)
                        }
                        .padding(.trailing, 5)
                        HollowHeaderView(postData: $postDataWrapper.post, compact: false)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, headerVerticalPadding)
                    Divider()
                }
                // Contents
                CustomScrollView { _ in
                    VStack(spacing: 13) {
                        Spacer(minLength: 5)
                            .fixedSize()
                        HollowContentView(postDataWrapper: $postDataWrapper, compact: false, voteHandler: {_ in})
                            .fixedSize(horizontal: false, vertical: true)
                        CommentView(comments: $postDataWrapper.post.comments)
                    }
                    .padding(.horizontal)
                    .background(Color.hollowDetailBackground)
                }
                .edgesIgnoringSafeArea(.bottom)
            }

        }
    }
}

extension HollowDetailView {
    private struct CommentView: View {
        @Binding var comments: [CommentData]
        var body: some View {
            VStack {
                (Text("\(comments.count) ") + Text(LocalizedStringKey("Comments")))
                    .fontWeight(.heavy)
                    .leading()
                    .padding(.top)
                    .padding(.bottom, 5)
                ForEach(comments.indices, id: \.self) { index in
                    HollowCommentContentView(commentData: $comments[index], compact: false)
                }
            }
        }
    }
}

struct HollowDetailView_Previews: PreviewProvider {

    static var previews: some View {
        return HollowDetailView(postDataWrapper: .constant(testPostDataWrapper), presentedIndex: .constant(-1)).colorScheme(.dark)
    }
}
