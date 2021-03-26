//
//  MainSubViews_iPad.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension MainView_iPad {
    
    @ViewBuilder var secondaryView: some View {
        switch sharedModel.page {
        case .timeline:
            TimelineView(isSearching: .constant(false), viewModel: sharedModel.timelineViewModel)
            .background(Color.background.ignoresSafeArea())
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitle("GLOBAL_TIMELINE", displayMode: .inline)
            .overlay(overlayFloatButton)
        case .wander:
            WanderView(showCreatePost: .constant(false), viewModel: sharedModel.wanderViewModel)
            .background(Color.background.ignoresSafeArea())
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitle("GLOBAL_WANDER", displayMode: .inline)
            .overlay(overlayFloatButton)
        case .search:
            SearchView(presented: .constant(true), store: .init(type: .search, options: [.unordered]))
            .navigationBarTitle("IPAD_SIDEBAR_SEARCH", displayMode: .inline)
        case .trending:
            SearchView(presented: .constant(true), store: .init(type: .searchTrending, options: [.unordered]))
                .navigationBarTitle("IPAD_SIDEBAR_TRENDING", displayMode: .inline)
        case .favourites:
            FavouritesView_iPad()
        case .notifications:
            MessageView.SystemMessageView(messageStore: MessageStore())
            .navigationBarTitle("IPAD_SIDEBAR_MESSAGES", displayMode: .inline)
            .padding(.leading)
            .edgesIgnoringSafeArea(.bottom)
            .background(Color.background.ignoresSafeArea())
        case .account:
            AccountInfoView()
            .edgesIgnoringSafeArea(.bottom)
            .navigationViewStyle(StackNavigationViewStyle())
        case .settings:
            SettingsView(presented: .constant(true))
            .edgesIgnoringSafeArea(.bottom)
            .navigationViewStyle(StackNavigationViewStyle())
        case .about:
            AboutView()
            .edgesIgnoringSafeArea(.bottom)
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    var overlayFloatButton: some View {
        Group { if !showCreatePost {
            FloatButton(
                action: {
                    withAnimation { showCreatePost = true }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                },
                systemImageName: "plus"
            )
            .bottom()
            .trailing()
            .padding()
            .padding(5)
            .padding(.bottom, 5)
        }}
        
    }
    
    struct FavouritesView_iPad: View {
        @State private var isSearching = false
        @State private var searchStore = PostListRequestStore(type: .attentionListSearch, options: .unordered)
        @State private var favouriteStore = PostListRequestStore(type: .attentionList)
        var body: some View {
            MessageView.AttentionListView(postListStore: favouriteStore, isSearching: $isSearching)
                .navigationBarTitle("IPAD_SIDEBAR_FAVOURITES", displayMode: .inline)
                .padding(.leading)
                .edgesIgnoringSafeArea(.bottom)
                .background(Color.background.ignoresSafeArea())
                .onChange(of: isSearching) { searching in
                    if searching {
                        IntegrationUtilities.pushViewOnSecondary {
                            SearchView(
                                presented: $isSearching,
                                store: searchStore,
                                showAdvancedOptions: false
                            )
                        }
                    }
                }
                .onAppear { isSearching = false }
        }
    }
}
