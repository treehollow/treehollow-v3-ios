//
//  HollowDetailView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct HollowDetailView: View {
    @ObservedObject var store: HollowDetailStore
    @Binding var presentedIndex: Int?
    
    @State private var commentRect: CGRect = .zero
    @State private var scrollViewOffset: CGFloat? = 0
    
    @ScaledMetric(wrappedValue: 10) var headerVerticalPadding: CGFloat
    
    var body: some View {
        // FIXME: Handlers
        ZStack {
            Color.hollowDetailBackground.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 0) {
                    HStack {
                        Button(action: { presentedIndex = nil }) {
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
                            voteHandler: store.vote
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer().frame(height: 0)
                            // Get the frame of the comment view.
                            .modifier(GetFrame(frame: $commentRect, coordinateSpace: .named("detail.scrollview.content")))

                        // Comment
                        let postData = store.postDataWrapper.post
                        (Text("\(postData.replyNumber) ") + Text("HOLLOWDETAIL_COMMENTS_COUNT_LABEL_SUFFIX"))
                            .fontWeight(.heavy)
                            .leading()
                            .padding(.top)
                            .padding(.bottom, 5)
                        let doubleTapAction: (Int) -> Void = { index in
                            let desComment = postData.comments[index].replyTo
                            guard desComment >= 0 else { return }
                            withAnimation { proxy.scrollTo(desComment, anchor: .center) }
                        }
                        if postData.comments.count > 30 {
                            LazyVStack {
                                ForEach(postData.comments.indices, id: \.self) { index in
                                    commentView(at: index, onDoubleTap: { doubleTapAction(index) })
                                    .id(postData.comments[index].commentId)
                                }
                            }
                        } else {
                            VStack {
                                ForEach(postData.comments.indices, id: \.self) { index in
                                    commentView(at: index, onDoubleTap: { doubleTapAction(index) })
                                    .id(postData.comments[index].commentId)
                                }
                            }

                        }
                        if store.isLoading {
                            LoadingLabel(foregroundColor: .primary).leading()
                        }
                    }
                    .padding(.horizontal)
                    .background(Color.hollowDetailBackground)
                    .coordinateSpace(name: "detail.scrollview.content")
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            
        }
        .modifier(ErrorAlert(errorMessage: $store.errorMessage))
        .modifier(AppModelBehaviour(state: store.appModelState))
        .animation(.default)
    }
    
    func commentView(at index: Int, onDoubleTap: @escaping () -> Void) -> some View {
        HollowCommentContentView(commentData: $store.postDataWrapper.post.comments[index], compact: false)
            .gesture(TapGesture(count: 2).onEnded(onDoubleTap))
    }
}
