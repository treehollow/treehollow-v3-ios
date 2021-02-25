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
                viewModel.loadMorePosts(clearPosts: false)
            },
            didScroll: { direction in withAnimation { showReload = direction == .up }},
            refresh: viewModel.refresh,
            content: { proxy in Group {
                WaterfallGrid(Array(viewModel.posts.enumerated()), id: \.element.id) { index, element in
                    HollowWanderCardView(postData: $viewModel.posts[index])
                        .onTapGesture {
                            detailStore = HollowDetailStore(
                                bindingPostWrapper: Binding(
                                    get: { PostDataWrapper(post: element, citedPost: nil) },
                                    set: { self.viewModel.posts[index] = $0.post }
                                )
                            )
                            DispatchQueue.main.async {
                                detailPresentedIndex = index
                            }
                        }
                        .disabled(viewModel.isLoading)
                        .id(index)
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
}
