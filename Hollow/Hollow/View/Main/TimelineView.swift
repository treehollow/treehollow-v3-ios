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
    @State private var detailPresentedIndex = -1
    
    @State private var offset: CGFloat? = 0
    var body: some View {
        // TODO: Show refresh button
        CustomScrollView(offset: $offset, refresh: { refresh in refresh = false }, content: {
            VStack(spacing: 0) {
                Button(action:{
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
                    .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.mainSearchBarBackground))
                    
                }
                .padding(.horizontal)
                .padding(.bottom)
                .padding(.top, 2)
                .background(Color.background)
                
                // FIXME: Performance issue with large number of posts.
                // Workaround: lazy load / hide previous cards
                
                LazyVStack(spacing: 0) {
                    ForEach(0..<viewModel.posts.count) { index in
                        HollowTimelineCardView(postDataWrapper: $viewModel.posts[index], viewModel: .init(voteHandler: { option in viewModel.vote(postId: viewModel.posts[index].post.postId, for: option)}))
                            .padding(.horizontal)
                            .padding(.bottom)
                            .background(Color.background)
                            .onTapGesture {
                                detailPresentedIndex = index
                            }
                            // FIXME: Cannot present after presenting and dismissing menu!
                            .fullScreenCover(isPresented: .constant(detailPresentedIndex == index), content: {
                                HollowDetailView(postDataWrapper: $viewModel.posts[index], presentedIndex: $detailPresentedIndex)
                            })
                    }
                }
            }
        })
        
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
