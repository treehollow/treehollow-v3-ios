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
        let originalComments = reverseComments ? postData.comments.reversed() : postData.comments
        
        let filteredCommentsByName = showOnlyName == nil ?
        originalComments :
        originalComments.filter({ $0.name == showOnlyName })
        
        let comments = searchString.isEmpty ?
        filteredCommentsByName :
        filteredCommentsByName.filter { $0.text.uppercased().contains(searchString.uppercased()) }

        HStack {
            if showOnlyName != nil || !searchString.isEmpty {
                
            }
            Text("\(showOnlyName != nil || !searchString.isEmpty ? String(comments.count) + " / " : "")\(postData.replyNumber) \(Text("HOLLOWDETAIL_COMMENTS_COUNT_LABEL_SUFFIX"))")
                .fontWeight(.heavy)
                .padding(.top)
                .padding(.bottom, 5)
                .padding(.bottom, UIDevice.isMac ? 20 : 13)
                .layoutPriority(1)
            
            Spacer()
            
            if let name = showOnlyName {
                Button(action: { withAnimation { showOnlyName = nil }}) {
                    HStack(spacing: 5) {
                        Text("\(Image(systemName: "person")) \(name)")
                        Image(systemName: "xmark")
                    }
                    .foregroundColor(.hollowCardStarUnselected)
                    .dynamicFont(size: 14, weight: .medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.background)
                    .clipShape(Capsule())
                }
                .padding(.trailing, 6)
            }
            
            Button(action: { reverseComments.toggle() }) {
                HStack(spacing: 5) {
                    Text(reverseComments ? "HOLLOWDETAIL_COMMENTS_ORDER_NEW_TO_OLD" : "HOLLOWDETAIL_COMMENTS_ORDER_OLD_TO_NEW")
                    Image(systemName: "arrow.up")
                        .rotationEffect(Angle(degrees: reverseComments ? 180 : 0))
                }
                .dynamicFont(size: 15, weight: .medium)
                .foregroundColor(.hollowCardStarUnselected)
                .animation(.defaultSpring, value: reverseComments)
            }
        }
        .padding(.horizontal)
        .lineLimit(1)
        .listRowBackground(Color.hollowCardBackground)
        .id(-3)
        
        ForEach(comments, id: \.commentId) { comment in
            commentView(for: comment)
                .fixedSize(horizontal: false, vertical: true)
                .id(comment.commentId)
        }
        
        let remainingCommentsCount = postData.replyNumber - postData.comments.count
        if store.isLoading, remainingCommentsCount > 0 {
            ForEach(0..<min(5, remainingCommentsCount), id: \.self) { _ in
                PlaceholderComment()
                    .padding(.horizontal)
                    .padding(.top, postData.comments.isEmpty ? 0 : 15)
                    .padding(.bottom, postData.comments.isEmpty ? 15 : 0)
                    .listRowBackground(Color.hollowCardBackground)
            }
        }
        
        if #available(iOS 15, *) {
            Spacer(minLength: commentViewBottomPadding)
        } else {
            Color.hollowCardBackground
                .frame(height: commentViewBottomPadding)
        }
    }
    
    func commentView(for comment: CommentData) -> some View {
        let hideLabel: Bool = showOnlyName == comment.name ?
            false :
            (reverseComments ? !comment.showAvatarWhenReversed : !comment.showAvatar)
        
        let bindingComment = Binding(
            get: { comment },
            set: { comment in
                if let index = store.postDataWrapper.post.comments.firstIndex(where: { $0.commentId == comment.commentId  }) {
                    store.postDataWrapper.post.comments[index] = comment
                }
            }
        )
        
        let highlighted = store.replyToId == comment.commentId || jumpedToCommentId == comment.commentId
        
        return HollowCommentContentView(
            commentData: bindingComment,
            compact: false,
            contentVerticalPadding: UIDevice.isMac ? 13 : 10,
            hideLabel: searchString.isEmpty ? hideLabel : false,
            postColorIndex: store.postDataWrapper.post.colorIndex,
            postHash: store.postDataWrapper.post.hash,
            imageReloadHandler: { store.reloadImage($0, commentId: comment.commentId) },
            jumpToReplyingHandler: { jumpToComment(commentId: comment.replyTo) }
        )
        .padding(.horizontal)
        .background(
            Group {
                highlighted ? Color.background : Color.hollowCardBackground
            }
        )
        .onClickGesture {
            guard !store.isSendingComment && !store.isLoading else { return }
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            withAnimation(scrollAnimation) {
                store.replyToId = comment.commentId
                jumpedToCommentId = nil
            }
        }
        .contextMenu {
            if comment.text != "" {
                Button(action: {
                    UIPasteboard.general.string = comment.text
                }, label: {
                    Label(NSLocalizedString("COMMENT_VIEW_COPY_TEXT_LABEL", comment: ""), systemImage: "doc.on.doc")
                })
            }
            
            if showOnlyName == nil {
                Button(action: { withAnimation { showOnlyName = comment.name } }) {
                    Label("COMMENT_VIEW_SHOW_ONLY_LABEL", systemImage: "line.horizontal.3.decrease.circle")
                }
                Divider()
            }
            
            ReportMenuContent(
                store: store,
                permissions: comment.permissions,
                commentId: comment.commentId
            )
            
            if #available(iOS 15.0, *) {} else {
                let text = comment.text
                
                let links = text.links(in: comment.rangesForLink)
                let citations = text.citationNumbers(in: comment.rangesForCitation)
                
                Divider()
                HyperlinkMenuContent(links: links, citations: citations)
            }

        }
    }
    
    func jumpToComment(commentId: Int) {
        withAnimation(scrollAnimation) { store.replyToId = -2 }
        withAnimation(scrollAnimation) { jumpedFromCommentId = commentId }
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
            HStack(alignment: .top, spacing: 0) {
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
