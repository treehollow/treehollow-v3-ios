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
    @State var replyIndex: Int = -2
    @State var inputPresented = false
    @Environment(\.presentationMode) var presentationMode
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
                            showContent: (scrollViewOffset ?? 0) > commentRect.minY
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
                            replyIndex = -1
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        }
                        
                        Spacer().frame(height: 0)
                            // Get the frame of the comment view.
                            .modifier(GetFrame(frame: $commentRect, coordinateSpace: .named("detail.scrollview.content")))
                        
                        commentView
                            .onChange(of: replyIndex) { index in
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    proxy.scrollTo(index, anchor: .top)
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
            if replyIndex >= -1 {
                let post = store.postDataWrapper.post
                let replyTo = replyIndex == -1 ? -1 : post.comments[replyIndex].commentId
                let name = replyIndex == -1 ?
                    NSLocalizedString("COMMENT_INPUT_REPLY_POST_SUFFIX", comment: "") :
                    post.comments[replyIndex].name
                let animation: Animation = .easeInOut(duration: 0.25)
                HollowCommentInputView(
                    store: .init(presented: $inputPresented, postId: post.postId, replyTo: replyTo, name: name, onFinishSending: store.requestDetail),
                    transitionAnimation: animation
                )
                .bottom()
                .transition(.move(edge: .bottom))
            }
        })

        .onChange(of: replyIndex) { index in
            if index >= -1 {
                withAnimation { inputPresented = true }
            }
        }
        .onChange(of: inputPresented) { presented in
            if !presented { withAnimation { replyIndex = -2 }}
        }
        .modifier(ErrorAlert(errorMessage: $store.errorMessage))
        .modifier(AppModelBehaviour(state: store.appModelState))
        .onDisappear(perform: store.cancelAll)
    }
    
}
