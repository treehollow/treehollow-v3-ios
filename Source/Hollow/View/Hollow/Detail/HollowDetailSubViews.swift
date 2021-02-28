//
//  HollowDetailSubViews.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension HollowDetailView {
    @ViewBuilder var commentView: some View {
        // Comment
        let postData = store.postDataWrapper.post
        (Text("\(postData.replyNumber) ") + Text("HOLLOWDETAIL_COMMENTS_COUNT_LABEL_SUFFIX"))
            .fontWeight(.heavy)
            .leading()
            .padding(.top)
            .padding(.bottom, 5)

        if postData.comments.count > 30 {
            LazyVStack {
                ForEach(postData.comments.indices, id: \.self) { index in
                    commentView(at: index)
                    .id(postData.comments[index].commentId)
                }
            }
        } else {
            VStack {
                ForEach(postData.comments.indices, id: \.self) { index in
                    commentView(at: index)
                    .id(postData.comments[index].commentId)
                }
            }

        }
        if store.isLoading {
            LoadingLabel(foregroundColor: .primary).leading()
        }
    }
    
    func commentView(at index: Int) -> some View {
        let hideLabel: Bool
        let comment = store.postDataWrapper.post.comments[index]
        if index == 0 { hideLabel = false }
        else { hideLabel = comment.name == store.postDataWrapper.post.comments[index - 1].name }
        return HollowCommentContentView(commentData: $store.postDataWrapper.post.comments[index], compact: false, hideLabel: hideLabel, imageReloadHandler: { store.reloadImage($0, commentId: comment.commentId) })
            .contentShape(Rectangle())
            .background(
                Group {
                    store.replyToIndex == index ? Color.background : Color.clear
                }
                .cornerRadius(10)
            )
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                store.replyToIndex = index
            }
    }

}
