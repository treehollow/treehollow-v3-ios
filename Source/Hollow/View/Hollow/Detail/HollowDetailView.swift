//
//  HollowDetailView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct HollowDetailView: View {
    @ObservedObject var store: HollowDetailStore
    
    @State private var headerFrame: CGRect = .zero
    @State private var commentViewFrame: CGRect = .zero
    @State var inputPresented = false
    @State var jumpedToIndex: Int?
    @State private var showHeaderContent = false
    
    private let scrollToAnchor = UnitPoint(x: 0.5, y: 0.1)
    
    @ScaledMetric(wrappedValue: 10) var headerVerticalPadding: CGFloat
    @ScaledMetric(wrappedValue: 11, relativeTo: .body) var commentHeaderPadding: CGFloat
    @ScaledMetric(wrappedValue: 16) var newCommentLabelSize: CGFloat
    
    @Environment(\.openURL) var openURL
    
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
                        
                        _HollowHeaderView(
                            postData: store.postDataWrapper.post,
                            compact: false,
                            // Show text on header when the text is not visible
//                            showContent: headerFrame.maxY > commentViewFrame.minY,
                            showContent: showHeaderContent,
                            starAction: store.star,
                            disableAttention: store.isEditingAttention || store.isLoading,
                            menuContent: { Group {
                                Button(action: store.requestDetail) {
                                    Label("DETAIL_MENU_REFRESH_LABEL", systemImage: "arrow.clockwise")
                                }
                                .disabled(store.isLoading)
                                
                                Divider()
                                
                                ReportMenuContent(
                                    store: store,
                                    permissions: store.postDataWrapper.post.permissions,
                                    commentId: nil
                                )
                                .disabled(store.isLoading)
                            }}
                        )
                        .disabled(store.noSuchPost)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, headerVerticalPadding)
                    Divider()
                }
//                .modifier(GetFrame(frame: $headerFrame))
                // Contents
                CustomScrollView { proxy in
                    VStack(spacing: 13) {
                        Spacer(minLength: 5)
                            .fixedSize()
                        Group { if store.noSuchPost {
                            HollowTextView(text: NSLocalizedString("DETAILVIEW_NO_SUCH_POST_PLACEHOLDER", comment: ""), inDetail: true, highlight: store.postDataWrapper.post.renderHighlight)
                        } else {
                            HollowContentView(
                                postDataWrapper: store.postDataWrapper,
                                options: [.displayVote, .displayImage, .displayCitedPost, .revealFoldTags, .showHyperlinks],
                                voteHandler: store.vote,
                                imageReloadHandler: { _ in store.loadPostImage() }
                            )
                            .fixedSize(horizontal: false, vertical: true)
                            .id(-1)
                        }}
                        .padding(.horizontal)
                        
                        Spacer().frame(height: 0)
                            // Get the frame of the comment view.
//                            .modifier(GetFrame(frame: $commentViewFrame))
                        
                        commentView
                            .onChange(of: store.replyToIndex) { index in
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    proxy.scrollTo(index, anchor: scrollToAnchor)
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
                                                proxy.scrollTo(index, anchor: scrollToAnchor)
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
                    .background(Color.hollowDetailBackground)
                    .coordinateSpace(name: "detail.scrollview.content")
                }
                .edgesIgnoringSafeArea(.bottom)
                .disabled(store.noSuchPost)
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
        
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    showHeaderContent = true
                }
            }
        }

        .modifier(ErrorAlert(errorMessage: $store.errorMessage))
        .modifier(AppModelBehaviour(state: store.appModelState))
    }
}

