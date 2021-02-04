//
//  HollowDetailView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct HollowDetailView: View {
    @Binding var postDataWrapper: PostDataWrapper
    @Binding var presentedIndex: Int
    var body: some View {
        // FIXME: Handlers
        ZStack {
            Color.hollowDetailBackground.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                // Header
                VStack {
                    HStack {
                        Button(action:{
                            // Navigate back
                            presentedIndex = -1
                        }) {
                            Image(systemName: "xmark")
                                .imageButton()
                                .padding(.trailing, 5)
                        }
                        .padding(.trailing, 5)
                        HollowHeaderView(viewModel: .init(starHandler: {_ in}), postData: $postDataWrapper.post, compact: false)
                    }
                    .padding(.horizontal)
                    Divider()
                }
                // Contents
                CustomScrollView {
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
                ForEach(comments) { comment in
                    HollowCommentContentView(commentData: .constant(comment), compact: false)
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
