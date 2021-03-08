//
//  TimelineView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct TimelineView: View {
    @Binding var isSearching: Bool

    @ObservedObject var viewModel: PostListRequestStore

    /// To track the offset when the user scroll to the middle of the searchbar.
    @State private var searchBarTrackingOffset: CGFloat?
    @State private var scrolledToBottom: Bool? = false
    @State private var scrollToIndex: Int = -1
    @State private var searchBarSize: CGSize = .zero
    
    @ScaledMetric(wrappedValue: 16, relativeTo: .body) var body16: CGFloat
    @ScaledMetric(wrappedValue: 17, relativeTo: .body) var body17: CGFloat
    @ScaledMetric(wrappedValue: 14, relativeTo: .body) var body14: CGFloat
    
    @State var detailStore: HollowDetailStore? = nil
    private var searchBarHeight: CGFloat { searchBarSize.height }
    
    /// Maximum cards to be displayed none-lazily.
    private let maxNoneLazyCards = 2
    
    var body: some View {
        CustomScrollView(
            didScrollToBottom: {
                if viewModel.allowLoadMorePosts {
                    viewModel.loadMorePosts()
                }
            },
            didEndScroll: { searchBarTrackingOffset = $0 },
            refresh: viewModel.refresh,
            content: { proxy in
                VStack(spacing: 0) {
                    SearchBar(isSearching: $isSearching)
                        .padding(.horizontal)
                        .padding(.bottom, body14 / 2)
                        .background(Color.background)
                        .modifier(GetSize(size: $searchBarSize))
                        .id(-2)
                    
                    Color.background.frame(height: body14 / 2)
                        .id(-1)
                    LazyVStack(spacing: 0) {
                        PostListView(
                            postDataWrappers: $viewModel.posts,
                            detailStore: $detailStore,
                            voteHandler: viewModel.vote,
                            starHandler: viewModel.star
                        )
                        .padding(.horizontal)
                    }

                }
                
                // Observe the change of the offset when the user finish scrolling,
                // then decide where to scroll based on the offset value.
                .onChange(of: searchBarTrackingOffset) { currentOffset in
                    guard let currentOffset = currentOffset else { return }
                    withAnimation(.spring(response: 0.05)) {
                        let threshold = searchBarHeight / 2
                        
                        // Perform scrolling actions
                        if currentOffset > 0 && currentOffset <= threshold {
                            // Reveal the search bar
                            proxy.scrollTo(-2, anchor: .top)
                        }
                        if currentOffset > threshold && currentOffset < searchBarHeight {
                            // Hide the search bar
                            proxy.scrollTo(-1, anchor: .top)
                        }
                        searchBarTrackingOffset = nil
                    }
                }
                
            })

            
            // Show loading indicator when no posts are loaded or refresh on top
            // TODO: refresh on top logic
            .modifier(LoadingIndicator(isLoading: viewModel.isLoading))
            
            .modifier(ErrorAlert(errorMessage: $viewModel.errorMessage))
            .modifier(AppModelBehaviour(state: viewModel.appModelState))
    }
    
}

extension Int: Identifiable {
    public var id: Int { self }
}
