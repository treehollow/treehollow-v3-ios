//
//  TimelineView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct TimelineView: View {
    @Binding var isSearching: Bool
    @ObservedObject var viewModel: Timeline = .init()
    @State private var detailPresentedIndex: Int?
    @State private var offset: CGFloat? = 0
    /// To track the offset when the user scroll to the middle of the searchbar.
    @State private var searchBarTrackingOffset: CGFloat?
    @State private var scrolledToBottom: Bool = false
    @State private var scrollToIndex: Int = -1
    
    @ScaledMetric(wrappedValue: 16, relativeTo: .body) var body16: CGFloat
    @ScaledMetric(wrappedValue: 17, relativeTo: .body) var body17: CGFloat
    @ScaledMetric(wrappedValue: 14, relativeTo: .body) var body14: CGFloat
    
    private var searchBarHeight: CGFloat {
        return
            body17 +    // font size
            14 +        // inner padding
            2 +         // top padding
            body14 / 2  // bottom padding
    }
    
    /// Maximum cards to be displayed none-lazily.
    private let maxNoneLazyCards = 2
    
    var body: some View {
        // TODO: Show refresh button
        CustomScrollView(
            offset: $offset,
            atBottom: Binding($scrolledToBottom),
            didScrollToBottom: viewModel.loadMorePosts,
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
                                .foregroundColor(.mainSearchBarBackground)
                        )
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, body14 / 2)
                    .background(Color.background)
                    .id(-1)
                    
                    // FIXME: Performance issue with large number of posts.
                    // Workaround: lazy load / hide previous cards
                    
                    // None lazy views for the first `maxNoneLazyCards` cards
                    // to avoid being stuck when scrolling to top
                    VStack(spacing: 0) {
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
                    
                    // TODO: Show retry button if failed.
                    if scrolledToBottom {
                        HStack {
                            Text(String.loadingLocalized.capitalized)
                                .font(.system(size: body16))
                            Spinner(color: .hollowContentText, desiredWidth: body16)
                        }
                        .foregroundColor(.hollowContentText)
                        .padding(.bottom)
                    }
                }
                
                // Set the offset for the preference key when the value changes.
                .preference(key: OffsetPreferenceKey.self, value: searchBarTrackingOffset)
                
                // Perform action when the value changes. Scroll to the top when
                // the current position is in the top half of the search bar,
                // and scroll to the first card if in the bottom half.
                .onPreferenceChange(OffsetPreferenceKey.self) { currentOffset in
                    guard let currentOffset = currentOffset else { return }
                    withAnimation(.spring(response: 0.05)) {
                        // Comensate the difference of the top and bottom padding.
                        let threshold = (searchBarHeight - (body14 - 2)) / 2
                        
                        // Perform scrolling actions
                        if currentOffset > 0 && currentOffset <= threshold {
                            proxy.scrollTo(-1, anchor: .top)
                        }
                        if currentOffset > threshold && currentOffset < searchBarHeight {
                            proxy.scrollTo(0, anchor: .top)
                        }
                        searchBarTrackingOffset = nil
                    }
                }
            })
            .sheet(item: $detailPresentedIndex, content: { index in
                HollowDetailView(postDataWrapper: $viewModel.posts[index], presentedIndex: $detailPresentedIndex)
            })
    }
    
    private func cardView(at index: Int) -> some View {
        HollowTimelineCardView(
            postDataWrapper: $viewModel.posts[index],
            viewModel: .init(voteHandler: { option in viewModel.vote(postId: viewModel.posts[index].post.postId, for: option)})
        )
        .padding(.top, index == 0 ? body14 / 2 : 0)
        .padding(.horizontal)
        .padding(.bottom)
        .background(Color.background)
        .onTapGesture {
            detailPresentedIndex = index
        }
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
