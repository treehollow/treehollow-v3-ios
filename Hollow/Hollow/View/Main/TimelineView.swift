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
    @Binding var showCreatePost: Bool
    @Binding var showReload: Bool
    @Binding var shouldReload: Bool

    @ObservedObject var viewModel: Timeline = .init()
    @EnvironmentObject var appModel: AppModel
    
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
                            Text("Search")
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
                    
                    Spacer().frame(height: body14 / 2)
                        .id(-1)
                    
                    // FIXME: Can we use postId as the id instead of the index?
                    // Using index will apply an imperfect animation on the cards
                    // (directly update the card content rather than moving the whole card).
                    
                    // None lazy views for the first `maxNoneLazyCards` cards
                    // to avoid being stuck when scrolling to top
                    VStack(spacing: 0) {
                        // Placeholder to fill the space when no posts are loaded
                        if viewModel.posts.count == 0 {
                            Spacer().horizontalCenter()
                        }
                        
                        ForEach(0..<min(maxNoneLazyCards, viewModel.posts.count), id: \.self) { index in
                            cardView(at: index)
                        }
                    }
                    
                    // Lazily load cards after `maxNoneLazyCards`
                    LazyVStack(spacing: 0) {
                        ForEach(min(maxNoneLazyCards, viewModel.posts.count)..<viewModel.posts.count, id: \.self) { index in
                            cardView(at: index)
                        }
                    }
                    
                    if viewModel.posts.count != 0 {
                        // TODO: Show retry button if failed.
                        LoadingLabel()
                            .padding(.bottom)
                            .padding(.bottom)
                        // TODO: Animation
                        // FIXME: Should show spinner after the request start processing
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
            .sheet(item: $detailPresentedIndex, content: { index in
                HollowDetailView(postDataWrapper: $viewModel.posts[index], presentedIndex: $detailPresentedIndex)
            })
            
            // Show loading indicator when no posts are loaded or refresh on top
            // TODO: refresh on top logic
            .modifier(LoadingIndicator(isLoading: viewModel.posts.count == 0))

    }
    
    private func cardView(at index: Int) -> some View {
        // FIXME: Disable the card interaction when refreshing!
        HollowTimelineCardView(
            postDataWrapper: $viewModel.posts[index],
            viewModel: .init(voteHandler: { option in viewModel.vote(postId: viewModel.posts[index].post.postId, for: option)})
        )
        .padding(.horizontal)
        .padding(.bottom)
        .background(Color.background)
        .onTapGesture {
            detailPresentedIndex = index
        }
//        .animation(.default)
        // Id for ScrollViewProxy to use
        .id(index)
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
