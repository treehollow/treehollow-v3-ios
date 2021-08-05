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
    var body14: CGFloat = 14
    
    @State var detailStore: HollowDetailStore? = nil
    @Default(.hollowConfig) var hollowConfig
    @Default(.hiddenAnnouncement) var hiddenAnnouncement
    
    @State private var announcementSheetPresented = false
    
    private let cardCornerRadius: CGFloat = UIDevice.isMac ? 17 : 13
    private let cardPadding: CGFloat? = UIDevice.isMac ? 25 : nil
    
    var body: some View {
        CustomList(didScrollToBottom: {
            if viewModel.allowLoadMorePosts {
                viewModel.loadMorePosts()
            }
        }, refresh: viewModel.refresh) {
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
                        .lineLimit(UIDevice.isPad ? nil : 10)
                        .fixedSize(horizontal: false, vertical: true)
                    
                }
                .padding(.all, cardPadding)
                .background(Color.hollowCardBackground)
                .roundedCorner(cardCornerRadius)
                .onTapGesture {
                    if !UIDevice.isPad {
                        announcementSheetPresented = true
                    }
                }
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
        
        .ignoresSafeArea(edges: .bottom)
        
        // Show loading indicator when no posts are loaded or refresh on top
        .modifier(LoadingIndicator(isLoading: viewModel.isLoading))
        
        .modifier(ErrorAlert(errorMessage: $viewModel.errorMessage))
        
        .sheet(isPresented: $announcementSheetPresented) {
            AnnouncementView(announcement: hollowConfig?.announcement ?? "")
        }
    }
    
}

extension TimelineView {
    private struct AnnouncementView: View {
        let announcement: String
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            NavigationView {
                ScrollView {
                    HollowTextView(text: announcement, highlight: true)
                        .padding()
                        .foregroundColor(.primary)
                        .accentColor(.hollowContentVoteGradient1)
                        .navigationBarTitle("TIMELINEVIEW_ANNOUCEMENT_CARD_TITLE")
                        .navigationBarItems(
                            trailing:
                                Button("VERSION_UPDATE_VIEW_CLOSE") {
                                    presentationMode.wrappedValue.dismiss()
                                }
                        )
                        .navigationBarTitleDisplayMode(.inline)
                }
                .background(Color.background.ignoresSafeArea())
            }
            .accentColor(.tint)
        }
    }
}
