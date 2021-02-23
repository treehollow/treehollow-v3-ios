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
    @State private var viewSize = CGSize()
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
                CustomScrollView(offset: $scrollViewOffset) { _ in
                    VStack(spacing: 13) {
                        Spacer(minLength: 5)
                            .fixedSize()
                        HollowContentView(postDataWrapper: store.postDataWrapper, compact: false, voteHandler: store.vote)
                            .fixedSize(horizontal: false, vertical: true)
                        CommentView(postData: $store.postDataWrapper.post, maxImageHeight: viewSize.height * 0.6)
                            // Get the frame of the comment view.
                            .modifier(GetFrame(frame: $commentRect, coordinateSpace: .named("detail.scrollview.content")))
                    }
                    .padding(.horizontal)
                    .background(Color.hollowDetailBackground)
                    .coordinateSpace(name: "detail.scrollview.content")
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            
        }
        .modifier(GetSize(size: $viewSize))
        .modifier(ErrorAlert(errorMessage: $store.errorMessage))
        .modifier(AppModelBehaviour(state: store.appModelState))
        .animation(.default)
    }
}

extension HollowDetailView {
    private struct CommentView: View {
        @Binding var postData: PostData
        var maxImageHeight: CGFloat?
        var body: some View {
            VStack {
                (Text("\(postData.replyNumber) ") + Text(LocalizedStringKey("Comments")))
                    .fontWeight(.heavy)
                    .leading()
                    .padding(.top)
                    .padding(.bottom, 5)
                ForEach(postData.comments.indices, id: \.self) { index in
                    HollowCommentContentView(commentData: $postData.comments[index], compact: false, maxImageHeight: maxImageHeight)
                }
            }
        }
    }
}

#if DEBUG
struct HollowDetailView_Previews: PreviewProvider {
    static var previews: some View {
        return HollowDetailView(store: .init(bindingPostWrapper: .constant(testPostWrappers[0])), presentedIndex: .constant(-1)).colorScheme(.dark)
    }
}
#endif
