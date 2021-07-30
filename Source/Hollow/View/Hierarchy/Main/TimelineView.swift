//
//  TimelineView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI
import Defaults
import Introspect

struct TimelineView: View {
    @Binding var isSearching: Bool
    
    @ObservedObject var viewModel: PostListRequestStore
    @ObservedObject var scrollViewModel = ScrollViewModel()
//    @State var offset: CGFloat = 0
    var body14: CGFloat = 14
    
    @State var detailStore: HollowDetailStore? = nil
    @Default(.hollowConfig) var hollowConfig
    @Default(.hiddenAnnouncement) var hiddenAnnouncement
    
    private let cardCornerRadius: CGFloat = UIDevice.isMac ? 17 : 13
    private let cardPadding: CGFloat? = UIDevice.isMac ? 25 : nil
    
    var body: some View {
        List {
            if !UIDevice.isPad {
                SearchBar(isSearching: $isSearching)
                    .padding(.horizontal)
                    .padding(.bottom, body14)
                    .background(Color.background)
                    .defaultListRow(backgroundColor: .background)
            }
            
            if let announcement = hollowConfig?.announcement,
               announcement != hiddenAnnouncement {
                VStack(alignment: .leading) {
                    HStack {
                        Label(
                            NSLocalizedString("TIMELINEVIEW_ANNOUCEMENT_CARD_TITLE", comment: ""),
                            systemImage: "megaphone"
                        )
                            .dynamicFont(size: 17, weight: .bold)
                            .foregroundColor(.hollowContentText)
                            .layoutPriority(1)
                        Spacer()
                        Button("TIMELINEVIEW_ANNOUNCEMENT_HIDE_BUTTON") { withAnimation {
                            hiddenAnnouncement = announcement
                        }}
                        .dynamicFont(size: 15)
                        .accentColor(.tint)
                    }
                    .lineLimit(1)
                    .padding(.bottom, 10)
                    
                    HollowTextView(text: announcement, highlight: true)
                        .foregroundColor(.hollowContentText)
                        .accentColor(.hollowContentVoteGradient1)
                    
                }
                .padding(.all, cardPadding)
                .background(Color.hollowCardBackground)
                .roundedCorner(cardCornerRadius)
                .padding(.horizontal, UIDevice.isMac ? 0 : nil)
                .defaultPadding(.bottom)
                .defaultListRow(backgroundColor: .background)
            }
            
            PostListView(
                postDataWrappers: $viewModel.posts,
                detailStore: $detailStore,
                voteHandler: viewModel.vote,
                starHandler: viewModel.star,
                imageReloadHandler: { _ in viewModel.fetchImages() }
            )
                .padding(.horizontal, UIDevice.isMac ? 0 : nil)
                .defaultListRow(backgroundColor: .background)
            
        }
        .listStyle(.plain)
        // FIXME: macOS padding
        //                .padding(UIDevice.isMac ? ViewConstants.macAdditionalPadding : 0)
        
        // Introspect UITableView rather than UIScrollView to
        // avoid unexpectedly discovering TabView's underlying
        // UIScrollView as our scroll view.
        .introspectTableView { tableView in
            print(tableView)
            (tableView as UIScrollView).delegate = scrollViewModel
        }
        // Refresh control on top.
        .refreshable {
            await withCheckedContinuation { continuation in
                viewModel.refresh(finshHandler: {
                    continuation.resume()
                })
            }
        }
        
        .onChange(of: scrollViewModel.scrolledToBottom) { scrolledToBottom in
            if scrolledToBottom && viewModel.allowLoadMorePosts {
                viewModel.loadMorePosts()
            }
        }
        
        .ignoresSafeArea(edges: .bottom)
        
        // Show loading indicator when no posts are loaded or refresh on top
        .modifier(LoadingIndicator(isLoading: viewModel.isLoading))
        
        .modifier(ErrorAlert(errorMessage: $viewModel.errorMessage))
    }
    
}

extension Int: Identifiable {
    public var id: Int { self }
}
