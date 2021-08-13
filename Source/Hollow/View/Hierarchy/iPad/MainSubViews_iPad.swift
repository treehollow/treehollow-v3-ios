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
                .navigationBarTitle("GLOBAL_TIMELINE", displayMode: .inline)
                .overlay(overlayFloatButton)
                .refreshNavigationItem(refreshAction: { sharedModel.timelineViewModel.refresh(finishHandler: {}) })
                .onAppear {
                    if sharedModel.timelineViewModel.posts.isEmpty {
                        sharedModel.timelineViewModel.requestPosts(at: 1)
                    }
                }
        case .wander:
            WanderView(showCreatePost: .constant(false), viewModel: sharedModel.wanderViewModel)
                .background(Color.background.ignoresSafeArea())
                .navigationBarTitle("GLOBAL_WANDER", displayMode: .inline)
                .overlay(overlayFloatButton)
                .refreshNavigationItem(refreshAction: { sharedModel.wanderViewModel.refresh(finishHandler: {}) })
                .onAppear {
                    if sharedModel.wanderViewModel.posts.isEmpty {
                        sharedModel.wanderViewModel.requestPosts(at: 1)
                    }
                }
        case .search:
            SearchView(presented: .constant(true), store: sharedModel.searchStore)
                .navigationBarTitle("IPAD_SIDEBAR_SEARCH", displayMode: .inline)
        case .trending:
            SearchView(presented: .constant(true), store: sharedModel.searchTrendingStore)
                .navigationBarTitle("IPAD_SIDEBAR_TRENDING", displayMode: .inline)
                .onAppear {
                    if sharedModel.searchTrendingStore.posts.isEmpty {
                        sharedModel.searchTrendingStore.requestPosts(at: 1)
                    }
                }
        case .favourites:
            FavouritesView_iPad(favouriteStore: sharedModel.favouriteStore)
        case .notifications:
            MessageView.SystemMessageView(messageStore: sharedModel.messageStore)
                .navigationBarTitle("IPAD_SIDEBAR_MESSAGES", displayMode: .inline)
                .padding(.leading)
                .background(Color.background.ignoresSafeArea())
                .refreshNavigationItem(refreshAction: { sharedModel.messageStore.requestMessages() })
                .onAppear {
                    if sharedModel.messageStore.messages.isEmpty {
                        sharedModel.messageStore.requestMessages()
                    }
                }
        case .account:
            AccountInfoView()
                .navigationViewStyle(StackNavigationViewStyle())
                .noNavigationItems()
        case .settings:
            SettingsView(presented: .constant(true))
                .navigationViewStyle(StackNavigationViewStyle())
                .noNavigationItems()
        case .about:
            AboutView()
                .navigationViewStyle(StackNavigationViewStyle())
                .noNavigationItems()
        }
    }
    
    var overlayFloatButton: some View {
        Group { if !sharedModel.showCreatePost {
            FloatButton(
                action: {
                    withAnimation { sharedModel.showCreatePost = true }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                },
                systemImageName: "plus",
                buttonAnimationNamespace: buttonAnimationNamespace
            )
            .keyboardShortcut("n")
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
        let favouriteStore: PostListRequestStore
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
                .refreshNavigationItem(refreshAction: { favouriteStore.refresh(finishHandler: {}) })
                .onAppear {
                    isSearching = false
                    if favouriteStore.posts.isEmpty {
                        favouriteStore.requestPosts(at: 1)
                    }
                }
        }
    }
}
