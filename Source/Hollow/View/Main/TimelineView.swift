//
//  TimelineView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI
import Defaults

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
    @Default(.hollowConfig) var hollowConfig
    @Default(.hiddenAnnouncement) var hiddenAnnouncement
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
                    
                    if let announcement = hollowConfig?.announcement,
                       announcement != hiddenAnnouncement {
                        VStack(alignment: .leading) {
                            Label(
                                NSLocalizedString("TIMELINEVIEW_ANNOUCEMENT_CARD_TITLE", comment: ""),
                                systemImage: "megaphone.fill"
                            )
                            .padding(.bottom, 10)
                            .dynamicFont(size: 17, weight: .bold)
                            .foregroundColor(.hollowContentText)
                            Text(announcement)
                                .dynamicFont(size: 16)
                            MyButton(action: { withAnimation {
                                hiddenAnnouncement = announcement
                            }}) {
                                Text("Hide")
                                    .dynamicFont(size: ViewConstants.plainButtonFontSize, weight: .bold)
                                    .foregroundColor(.white)
                            }
                            .trailing()
                        }
                        .padding()
                        .background(Color.hollowCardBackground)
                        .roundedCorner(13)
                        .padding([.bottom, .horizontal])
                    }
                    
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
