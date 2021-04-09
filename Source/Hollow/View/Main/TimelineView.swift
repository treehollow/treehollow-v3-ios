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
    
    @ScaledMetric(wrappedValue: 14, relativeTo: .body) var body14: CGFloat
    
    @State var detailStore: HollowDetailStore? = nil
    @Default(.hollowConfig) var hollowConfig
    @Default(.hiddenAnnouncement) var hiddenAnnouncement
    private var searchBarHeight: CGFloat { searchBarSize.height }
    
    private let cardCornerRadius: CGFloat = UIDevice.isMac ? 17 : 13
    private let cardPadding: CGFloat? = UIDevice.isMac ? 25 : nil
    
    /// Maximum cards to be displayed none-lazily.
    private let maxNoneLazyCards = 2
    
    var body: some View {
        CustomScrollView(
            didScrollToBottom: {
                if viewModel.allowLoadMorePosts {
                    viewModel.loadMorePosts()
                }
            },
            didEndScroll: {
                if !UIDevice.isPad { searchBarTrackingOffset = $0 }
            },
            refresh: viewModel.refresh,
            content: { proxy in
                LazyVStack(spacing: 0) {
                    if !UIDevice.isPad {
                        SearchBar(isSearching: $isSearching)
                            .padding(.horizontal)
                            .padding(.bottom, body14 / 2)
                            .background(Color.background)
                            .modifier(GetSize(size: $searchBarSize))
                            .id(-2)
                    }
                    
                    Color.background.frame(height: body14 / 2)
                        .id(-1)
                    
                    if let announcement = hollowConfig?.announcement,
                       announcement != hiddenAnnouncement {
                        VStack(alignment: .leading) {
                            Label(
                                NSLocalizedString("TIMELINEVIEW_ANNOUCEMENT_CARD_TITLE", comment: ""),
                                systemImage: "megaphone"
                            )
                            .padding(.bottom, 10)
                            .dynamicFont(size: 17, weight: .bold)
                            .foregroundColor(.hollowContentText)
                            HollowTextView(text: announcement, inDetail: true, highlight: true)
                            MyButton(action: { withAnimation {
                                hiddenAnnouncement = announcement
                            }}) {
                                Text("TIMELINEVIEW_ANNOUNCEMENT_HIDE_BUTTON")
                                    .dynamicFont(size: ViewConstants.plainButtonFontSize, weight: .bold)
                                    .foregroundColor(.white)
                            }
                            .trailing()
                        }
                        .padding(.all, cardPadding)
                        .background(Color.hollowCardBackground)
                        .roundedCorner(cardCornerRadius)
                        .padding(.horizontal, UIDevice.isMac ? 0 : nil)
                        .defaultPadding(.bottom)
                    }
                    
                    PostListView(
                        postDataWrappers: $viewModel.posts,
                        detailStore: $detailStore,
                        voteHandler: viewModel.vote,
                        starHandler: viewModel.star,
                        imageReloadHandler: { _ in viewModel.fetchImages() }
                    )
                    .padding(.horizontal, UIDevice.isMac ? 0 : nil)

                }
                .padding(UIDevice.isMac ? ViewConstants.macAdditionalPadding : 0)
                
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
