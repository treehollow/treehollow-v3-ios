//
//  TimelineView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI
import WaterfallGrid

struct TimelineView: View {
    @Binding var isSearching: Bool
    @Binding var showReload: Bool
    @Binding var shouldReload: Bool

    @ObservedObject var viewModel: PostListRequestStore
    
    @State private var detailPresentedIndex: Int?
    @State private var offset: CGFloat? = 0
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
            offset: $offset,
            atBottom: $scrolledToBottom,
            didScrollToBottom: viewModel.loadMorePosts,
            didScroll: { direction in withAnimation { showReload = direction == .up }},
            didEndScroll: { searchBarTrackingOffset = offset },
            refresh: viewModel.refresh,
            content: { proxy in
                VStack(spacing: 0) {
                    Button(action:{
                        // FIXME: Ugly animation here
                        // Navigate to search view
                        withAnimation(.searchViewTransition) {
                            isSearching = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("TIMELINE_SEARCH_BAR_PLACEHOLDER")
                            Spacer()
                        }
                        .font(.system(size: body17))
                        .foregroundColor(.mainSearchBarText)
                        .padding(.vertical, 7)
                        .padding(.horizontal, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color.mainSearchBarBackground.opacity(0.6))
                        )
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, body14 / 2)
                    .background(Color.background)
                    .modifier(GetSize(size: $searchBarSize))
                    .id(-2)
                    
                    Color.background.frame(height: body14 / 2)
                        .id(-1)
                    LazyVStack(spacing: 0) {
                        HollowTimeilneListView(
                            postDataWrappers: $viewModel.posts,
                            detailStore: $detailStore,
                            detailPresentedIndex: $detailPresentedIndex,
                            voteHandler: viewModel.vote)
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
                
                // Receive the notification of performing reload from the main view
                .onChange(of: shouldReload) { _ in
                    if shouldReload { withAnimation {
                        proxy.scrollTo(-1, anchor: .top)
                        viewModel.refresh(finshHandler: {})
                        shouldReload = false
                    }}
                }
                
            })

            // Present post detail
            .sheet(item: $detailPresentedIndex, content: { index in Group {
                if let store = detailStore {
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

extension TimelineView {
    struct OffsetPreferenceKey: PreferenceKey {
        typealias Value = CGFloat?

        static var defaultValue: CGFloat? = nil
        
        static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
            value = nextValue()
        }
    }
}

#if DEBUG
struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
#endif

extension Int: Identifiable {
    public var id: Int { self }
}
