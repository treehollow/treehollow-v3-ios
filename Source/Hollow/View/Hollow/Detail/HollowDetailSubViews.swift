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
        let postData = store.postDataWrapper.post
        
        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
            Section(
                header:
                    VStack(spacing: 0) {
                        HStack {
                            (Text("\(postData.replyNumber) ") + Text("HOLLOWDETAIL_COMMENTS_COUNT_LABEL_SUFFIX"))
                                .fontWeight(.heavy)
                            Spacer()
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                store.replyToIndex = -1
                            }) {
                                Text("HOLLOWDETAIL_COMMENTS_NEW_COMMENT_BUTTON")
                                    .fontWeight(.medium)
                                    .font(.system(size: newCommentLabelSize))
                                    .lineLimit(1)
                            }
                            .accentColor(.hollowContentVoteGradient1)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, commentHeaderPadding)
                        .background(Color.hollowDetailBackground)
                    }
                
            ) {
                ForEach(postData.comments) { comment in
                    commentView(for: comment)
                }
                .padding(.horizontal)
            }
        }

        if store.isLoading {
            LoadingLabel(foregroundColor: .primary)
                .leading()
                .padding(.horizontal)
        }
    }
    
    func commentView(for comment: CommentData) -> some View {
        var hideLabel: Bool = false
        let index = store.postDataWrapper.post.comments.firstIndex(where: { $0.commentId == comment.commentId })
        if index == 0 { hideLabel = false }
        else if let index = index {
            hideLabel = comment.name == store.postDataWrapper.post.comments[index - 1].name
        }
        return Group { if let index = index {
            let bindingComment = Binding(
                get: { comment },
                set: { comment in
                    if let index = store.postDataWrapper.post.comments.firstIndex(where: { $0.commentId == comment.commentId  }) {
                        store.postDataWrapper.post.comments[index] = comment
                    }
                }
            )
            HollowCommentContentView(commentData: bindingComment, compact: false, hideLabel: hideLabel, postColorIndex: store.postDataWrapper.post.colorIndex, imageReloadHandler: { store.reloadImage($0, commentId: comment.commentId) })
                .id(index)
                .contentShape(RoundedRectangle(cornerRadius: 10))
                .background(
                    Group {
                        store.replyToIndex == index || jumpedToIndex == index ?
                            Color.background : nil
                    }
                    .roundedCorner(10)
                    .animation(.none)
                )
                .onTapGesture {
                    guard !store.isSendingComment else { return }
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    store.replyToIndex = index
                    jumpedToIndex = nil
                }
                .contextMenu {
                    if comment.text != "" {
                        Button(action: {
                            UIPasteboard.general.string = comment.text
                        }, label: {
                            Label(NSLocalizedString("COMMENT_VIEW_COPY_TEXT_LABEL", comment: ""), systemImage: "plus.square.on.square")
                        })
                        Divider()
                    }
                    if comment.hasURL {
                        let links = Array(comment.text.links().compactMap({ URL(string: $0) }))
                        Divider()
                        ForEach(links, id: \.self) { link in
                            Button(action: {
                                let helper = OpenURLHelper(openURL: openURL)
                                try? helper.tryOpen(link)
                            }) {
                                Label(link.absoluteString, systemImage: "link")
                            }
                        }
                        Divider()
                    }
                    if comment.hasCitedNumbers {
                        let citedPosts = comment.text.citationNumbers()
                        ForEach(citedPosts, id: \.self) { post in
                            let wrapper = PostDataWrapper.templatePost(for: post)
                            Button(action: {
                                presentView {
                                    HollowDetailView(store: .init(bindingPostWrapper: .constant(wrapper)))
                                }
                            }) {
                                Label("#\(post.string)", systemImage: "text.quote")
                            }
                        }
                        Divider()
                    }
                    ReportMenuContent(
                        store: store,
                        permissions: comment.permissions,
                        commentId: comment.commentId
                    )
                }
            
        }}
    }
}
