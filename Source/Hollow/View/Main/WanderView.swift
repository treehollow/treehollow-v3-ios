//
//  WanderView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI
import WaterfallGrid

struct WanderView: View {
    @State private var scrolledToBottom: Bool? = false
    @State private var shouldLoadMorePosts = true
    @State private var detailPresentedIndex: Int?
    
    @Binding var showCreatePost: Bool
    
    @ObservedObject var viewModel: PostListRequestStore
    
    @ScaledMetric(wrappedValue: 5, relativeTo: .body) var body5: CGFloat
    
    
    var body: some View {
        CustomScrollView(
            didScrollToBottom: {
                // We won't allow updating when the detail
                // view is presenting
                guard detailPresentedIndex == nil else { return }
                // Due to performance issue of WaterfallGrid, we set the
                // maximum number of posts to 60 (at least loading for 2 times)
                if viewModel.posts.count >= 60 {
                    viewModel.posts.removeAll()
                    viewModel.allowLoadMorePosts = true
                }
                viewModel.loadMorePosts()
            },
            refresh: viewModel.refresh,
            content: { proxy in
                Group {
                    WaterfallGrid(viewModel.posts) { postDataWrapper in Group {
                        let postData = postDataWrapper.post
                        cardView(for: postData)
                            .onClickGesture {
                                IntegrationUtilities.conditionallyPresentView(content: {
                                    HollowDetailView.conditionalDetailView(store: HollowDetailStore(
                                        bindingPostWrapper: Binding(
                                            get: { postDataWrapper },
                                            set: {
                                                guard let index = viewModel.posts.firstIndex(where: { $0.post.id == postData.id }) else { return }
                                                self.viewModel.posts[index] = $0
                                            }
                                        )
                                    ))
                                    
                                })
                            }
                    }}
                    .gridStyle(columns: 2, spacing: UIDevice.isMac ? 18 : 10, animation: nil)
                    .padding(.horizontal, UIDevice.isMac ? ViewConstants.macAdditionalPadding : 15)
                    .padding(.bottom, 70)
                    .background(Color.background)
                }
            })
            
            // Show loading indicator when no posts are loaded or refresh on top
            // TODO: refresh on top logic
            .modifier(LoadingIndicator(isLoading: viewModel.isLoading))
            
            .modifier(ErrorAlert(errorMessage: $viewModel.errorMessage))
            .modifier(AppModelBehaviour(state: viewModel.appModelState))
    }
    
    func cardView(for postData: PostData) -> some View {
        VStack {
            HollowHeaderView(
                postData: postData,
                compact: true,
                starAction: { viewModel.star($0, for: postData.postId) },
                disableAttention: false
            )
            .padding(.bottom, body5)
            
            VStack {
                HollowContentView(
                    postDataWrapper: .init(post: postData, citedPost: nil),
                    options: [.displayVote, .disableVote, .displayImage, .replaceForImageOnly, .compactText, .lowerImageAspectRatio],
                    voteHandler: { _ in },
                    lineLimit: 20
                )
            }
            
            HStack {
                numberLabel(count: postData.replyNumber, systemImage: "quote.bubble")
                    .foregroundColor(.hollowCardStarUnselected)
                Spacer()
                numberLabel(count: postData.likeNumber, systemImage: postData.attention ? "star.fill" : "star")
                    .foregroundColor(postData.attention ? .hollowCardStarSelected : .hollowCardStarUnselected)
            }
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .padding(.top, body5)
            .padding(.horizontal, 5)
        }
        .padding()
        .background(Color.hollowCardBackground)
        .roundedCorner(20)
    }
    
    private func numberLabel(count: Int, systemImage: String) -> some View {
        (Text(Image(systemName: systemImage)) + Text("  \(count)"))
            .singleLineText()
    }
}
