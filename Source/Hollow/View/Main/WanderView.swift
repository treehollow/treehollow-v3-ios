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
                }
                viewModel.loadMorePosts()
            },
            refresh: viewModel.refresh,
            content: { proxy in Group {
                WaterfallGrid(viewModel.posts) { postDataWrapper in Group {
                    let postData = postDataWrapper.post
                    cardView(for: postData)
                        .onTapGesture {
                            guard let index = viewModel.posts.firstIndex(where: { $0.post.id == postData.id }) else { return }
                            presentView {
                                HollowDetailView(store: HollowDetailStore(
                                    bindingPostWrapper: Binding(
                                        get: { postDataWrapper },
                                        set: { self.viewModel.posts[index] = $0 }
                                    )
                                ))
                            }
                        }
                        .disabled(viewModel.isLoading)
                }}
                .gridStyle(columns: 2, spacing: 10, animation: nil)
                .padding(.horizontal, 15)
                .padding(.bottom, 70)
                .background(Color.background)
            }})

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
                    options: [.displayVote, .disableVote, .displayImage, .replaceForImageOnly, .compactText],
                    voteHandler: { _ in },
                    lineLimit: 20
                    // TODO: Reload handler
                )
            }

            HStack {
                Label("\(postData.replyNumber)", systemImage: "quote.bubble")
                    .foregroundColor(.hollowCardStarUnselected)
                Spacer()
                Label("\(postData.likeNumber)", systemImage: postData.attention ? "star.fill" : "star")
                    .foregroundColor(postData.attention ? .hollowCardStarSelected : .hollowCardStarUnselected)
            }
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .padding(.top, body5)
            .padding(.horizontal, 5)
        }
        .padding()
        .background(Color.hollowCardBackground)
        .cornerRadius(20)
    }
}
