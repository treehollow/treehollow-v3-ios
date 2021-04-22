//
//  HollowDetailSubViews.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

extension HollowDetailView {
    @ViewBuilder var commentView: some View {
        let postData = store.postDataWrapper.post
        
        (Text("\(postData.replyNumber) ") + Text("HOLLOWDETAIL_COMMENTS_COUNT_LABEL_SUFFIX"))
            .fontWeight(.heavy)
            .leading()
            .padding(.top)
            .padding(.bottom, 5)
            .padding(.bottom, UIDevice.isMac ? 20 : 13)
        
        ForEach(postData.comments) { comment in
            commentView(for: comment)
        }
        
        if store.isLoading, postData.replyNumber > postData.comments.count {
            ForEach(0..<postData.replyNumber - postData.comments.count, id: \.self) { _ in
                PlaceholderComment()
                    .padding(.top, postData.comments.isEmpty ? 0 : 15)
                    .padding(.bottom, postData.comments.isEmpty ? 15 : 0)
            }
        }

        Spacer(minLength: commentViewBottomPadding)
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
            HollowCommentContentView(commentData: bindingComment, compact: false, contentVerticalPadding: UIDevice.isMac ? 13 : 10, hideLabel: hideLabel, postColorIndex: store.postDataWrapper.post.colorIndex, postHash: store.postDataWrapper.post.hash, imageReloadHandler: { store.reloadImage($0, commentId: comment.commentId) })
                .id(index)
                .contentShape(RoundedRectangle(cornerRadius: 10))
                .background(
                    Group {
                        store.replyToIndex == index || jumpedToIndex == index ?
                            Color.background : nil
                    }
                    .roundedCorner(10)
//                    .animation(.none)
                    .transition(.opacity)
                )
                .onClickGesture {
                    guard !store.isSendingComment && !store.isLoading else { return }
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    withAnimation(scrollAnimation) {
                        store.replyToIndex = index
                        jumpedToIndex = nil
                    }
                }
                .contextMenu {
                    if comment.text != "" {
                        Button(action: {
                            UIPasteboard.general.string = comment.text
                        }, label: {
                            Label(NSLocalizedString("COMMENT_VIEW_COPY_TEXT_LABEL", comment: ""), systemImage: "doc.on.doc")
                        })
                        Divider()
                    }
                    if comment.replyTo != -1 {
                        Button(action: {
                            let comments = store.postDataWrapper.post.comments
                            guard let index = comments.firstIndex(where: {$0.commentId == comment.replyTo}) else { return }
                            jumpedIndexFromComment = index
                        }) {
                            Label("COMMENT_VIEW_JUMP_LABEL", systemImage: "text.quote")
                        }
                    }
                    if comment.hasURL {
                        let links = Array(comment.text.links().compactMap({ URL(string: $0) }))
                        Divider()
                        ForEach(links, id: \.self) { link in
                            Button(action: {
                                let helper = OpenURLHelper(openURL: openURL)
                                try? helper.tryOpen(link, method: Defaults[.openURLMethod])
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
                                IntegrationUtilities.conditionallyPresentView {
                                    HollowDetailView.conditionalDetailView(store: .init(bindingPostWrapper: .constant(wrapper)))
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
    
    struct PlaceholderComment: View {
        @State private var flash = false
        @ScaledMetric(wrappedValue: 50) var textHeight: CGFloat
        @ScaledMetric(wrappedValue: 7) var textCorner: CGFloat
        @ScaledMetric(wrappedValue: 5) var nameCorner: CGFloat
        
        @ViewBuilder var body: some View {
            // keep in sync with HollowCommentContentView
            let avatarWidth = HollowCommentContentView.avatarWidth
            let circleWidth = avatarWidth * HollowCommentContentView.avatarProportion + 4
            HStack(alignment: .top) {
                Circle()
                    .frame(width: circleWidth, height: circleWidth)
                    .leading()
                    .frame(width: avatarWidth)
                    .offset(x: -2)
                VStack {
                    Text("liang2kl")
                        .foregroundColor(.clear)
                        .overlay(RoundedRectangle(cornerRadius: nameCorner, style: .continuous))
                        .leading()
                    RoundedRectangle(cornerRadius: textCorner, style: .continuous)
                        .frame(height: textHeight)
                }
            }
            .foregroundColor(.uiColor(flash ? .systemFill : .tertiarySystemFill))
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                    flash.toggle()
                }
            }
        }
    }
}
