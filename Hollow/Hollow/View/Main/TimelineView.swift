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
    
    /// Maximum cards to be displayed none-lazily.
    private let maxNoneLazyCards = 1
    
    var body: some View {
        // TODO: Show refresh button
        CustomScrollView(offset: $offset, refresh: { refresh in refresh = false }, content: {
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
                    .foregroundColor(.mainSearchBarText)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.mainSearchBarBackground)
                    )
                    
                }
                .padding(.horizontal)
                .padding(.bottom)
                .padding(.top, 2)
                .background(Color.background)
                
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
                if maxNoneLazyCards < viewModel.posts.count {
                    LazyVStack(spacing: 0) {
                        ForEach(min(maxNoneLazyCards, viewModel.posts.count)..<viewModel.posts.count, id: \.self) { index in
                            cardView(at: index)
                        }
                    }
                }
            }
        })
        
    }
    
    private func cardView(at index: Int) -> some View {
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
        .sheet(item: $detailPresentedIndex, content: { index in
            HollowDetailView(postDataWrapper: $viewModel.posts[index], presentedIndex: $detailPresentedIndex)
        })
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

extension Int: Identifiable {
    public var id: Int { self }
}
