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
    @State private var detailStore: HollowDetailStore? = nil
    @State private var detailPresentedIndex: Int?
    
    @Binding var showCreatePost: Bool
    @Binding var showReload: Bool
    @Binding var shouldReload: Bool
    
    @ObservedObject var viewModel: Wander
    
    @ScaledMetric(wrappedValue: 5, relativeTo: .body) var body5: CGFloat

    
    var body: some View {
        CustomScrollView(
            didScrollToBottom: {
                // We won't allow updating when the detail
                // view is presenting
                guard detailPresentedIndex == nil else { return }
                // Due to performance issue of WaterfallGrid, we set the
                // maximum number of posts to 90 (at least loading for 3 times)
                if viewModel.posts.count >= 90 {
                    viewModel.posts.removeAll()
                }
                viewModel.loadMorePosts(clearPosts: false)
            },
            didScroll: { direction in withAnimation { showReload = direction == .up }},
            refresh: viewModel.refresh,
            content: { proxy in Group {
                WaterfallGrid(viewModel.posts) { postData in
                    cardView(for: postData)
                        .onTapGesture {
                            guard let index = viewModel.posts.firstIndex(where: { $0.id == postData.id }) else { return }
                            detailStore = HollowDetailStore(
                                bindingPostWrapper: Binding(
                                    get: { PostDataWrapper(post: postData, citedPost: nil) },
                                    set: { self.viewModel.posts[index] = $0.post }
                                )
                            )
                            DispatchQueue.main.async {
                                detailPresentedIndex = index
                            }
                        }
                        .disabled(viewModel.isLoading)
                }
                .gridStyle(columns: 2, spacing: 10, animation: nil)
                .padding(.horizontal, 15)
                .background(Color.background)
                .onChange(of: shouldReload) { _ in
                    if shouldReload { withAnimation {
                        proxy.scrollTo(0, anchor: .top)
                        viewModel.refresh()
                    }}
                }
                
                LoadingLabel()
                    .padding(.vertical)
                    .padding(.bottom)
            }})
            // Present post detail
            .sheet(item: $detailPresentedIndex, content: { index in Group {
                if let store = detailStore {
                    // FIXME: Data binding
                    HollowDetailView(store: store, presentedIndex: $detailPresentedIndex)
                }
            }})

            // Show loading indicator when no posts are loaded or refresh on top
            // TODO: refresh on top logic
            .modifier(LoadingIndicator(isLoading: viewModel.isLoading))
            
            .modifier(ErrorAlert(errorMessage: $viewModel.errorMessage))
            .modifier(AppModelBehaviour(state: viewModel.appModelState))
    }
    
    func cardView(for postData: PostData) -> some View {
        VStack {
            HollowHeaderView(postData: postData, compact: true)
                .padding(.bottom, body5)
            VStack {
                HollowContentView(
                    postDataWrapper: .init(post: postData, citedPost: nil),
                    options: [.displayVote, .disableVote, .displayImage, .replaceForImageOnly, .compactText],
                    voteHandler: { _ in },
                    lineLimit: 20
                )
            }
            // TODO: Vote and cite
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
