//
//  HollowDetailView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct HollowDetailView: View {
    @Binding var postDataWrapper: PostDataWrapper
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
                            postData: postDataWrapper.post,
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
                        HollowContentView(postDataWrapper: postDataWrapper, compact: false, voteHandler: {_ in})
                            .fixedSize(horizontal: false, vertical: true)
                        CommentView(comments: $postDataWrapper.post.comments, maxImageHeight: viewSize.height * 0.6)
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
    }
}

extension HollowDetailView {
    private struct CommentView: View {
        @Binding var comments: [CommentData]
        var maxImageHeight: CGFloat?
        var body: some View {
            VStack {
                (Text("\(comments.count) ") + Text(LocalizedStringKey("Comments")))
                    .fontWeight(.heavy)
                    .leading()
                    .padding(.top)
                    .padding(.bottom, 5)
                ForEach(comments) { commentData in
                    HollowCommentContentView(commentData: commentData, compact: false, maxImageHeight: maxImageHeight)
                }
            }
        }
    }
}

#if DEBUG
struct HollowDetailView_Previews: PreviewProvider {
    static var previews: some View {
        return HollowDetailView(postDataWrapper: .constant(testPostDataWrapper), presentedIndex: .constant(-1)).colorScheme(.dark)
    }
}
#endif
