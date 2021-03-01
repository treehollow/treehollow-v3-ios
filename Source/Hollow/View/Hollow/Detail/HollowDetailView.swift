//
//  HollowDetailView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct HollowDetailView: View {
    @ObservedObject var store: HollowDetailStore
    
    @State private var commentRect: CGRect = .zero
    @State private var scrollViewOffset: CGFloat? = 0
    @State var inputPresented = false
    @State var jumpedToIndex: Int?
    
    @ScaledMetric(wrappedValue: 10) var headerVerticalPadding: CGFloat
    
    var body: some View {
        // FIXME: Handlers
        ZStack {
            Color.hollowDetailBackground.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 0) {
                    HStack {
                        Button(action: dismissSelf) {
                            Image(systemName: "xmark")
                                .modifier(ImageButtonModifier())
                                .padding(.trailing, 5)
                        }
                        .padding(.trailing, 5)
                        
                        HollowHeaderView(
                            postData: store.postDataWrapper.post,
                            compact: false,
                            // Show text on header when the text is not visible
                            showContent: (scrollViewOffset ?? 0) > commentRect.minY,
                            starAction: store.star,
                            disableAttention: store.isEditingAttention || store.isLoading
                        )
                    }
                    .padding(.horizontal)
                    .padding(.vertical, headerVerticalPadding)
                    Divider()
                }
                // Contents
                CustomScrollView(offset: $scrollViewOffset) { proxy in
                    VStack(spacing: 13) {
                        Spacer(minLength: 5)
                            .fixedSize()
                        HollowContentView(
                            postDataWrapper: store.postDataWrapper,
                            options: [.displayVote, .displayImage, .displayCitedPost, .revealFoldTags],
                            voteHandler: store.vote,
                            imageReloadHandler: { _ in store.loadPostImage() }
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        .id(-1)
                        .onTapGesture {
                            store.replyToIndex = -1
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        }
                        
                        Spacer().frame(height: 0)
                            // Get the frame of the comment view.
                            .modifier(GetFrame(frame: $commentRect, coordinateSpace: .named("detail.scrollview.content")))
                        
                        commentView
                            .onChange(of: store.replyToIndex) { index in
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    proxy.scrollTo(index, anchor: .top)
                                }
                            }
                            // Jump to certain comment
                            .onChange(of: store.isLoading) { loading in
                                if !loading {
                                    // Check if there is any comment to jump to
                                    // when finish loading
                                    if let jumpToCommentId = store.jumpToCommentId {
                                        if let index = store.postDataWrapper.post.comments.firstIndex(where: { $0.commentId == jumpToCommentId }) {
                                            withAnimation {
                                                proxy.scrollTo(index, anchor: .center)
                                                jumpedToIndex = index
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                withAnimation { jumpedToIndex = nil }
                                            }
                                        }
                                        store.jumpToCommentId = nil
                                    }
                                }
                            }
                    }
                    .padding(.horizontal)
                    .background(Color.hollowDetailBackground)
                    .coordinateSpace(name: "detail.scrollview.content")
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .overlay(Group {
            if store.replyToIndex >= -1 {
                let post = store.postDataWrapper.post
                let name = store.replyToIndex == -1 ?
                    NSLocalizedString("COMMENT_INPUT_REPLY_POST_SUFFIX", comment: "") :
                    post.comments[store.replyToIndex].name
                let animation: Animation = .easeInOut(duration: 0.25)
                // FIXME: Recreated store
                HollowCommentInputView(
                    store: store,
                    transitionAnimation: animation,
                    replyToName: name
                )
                .bottom()
                .transition(.move(edge: .bottom))
            }
        })

        .onChange(of: store.replyToIndex) { index in
            if index >= -1 {
                withAnimation { inputPresented = true }
            }
        }
        .onChange(of: inputPresented) { presented in
            if !presented { withAnimation { store.replyToIndex = -2 }}
        }
        .modifier(ErrorAlert(errorMessage: $store.errorMessage))
        .modifier(AppModelBehaviour(state: store.appModelState))
    }
    
}
