//
//  MainSubViews_iPad.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension MainView_iPad {
    var topSection: some View {
        Group {
            NavigationLink(
                destination:
                    TimelineView(isSearching: .constant(false), viewModel: timelineViewModel)
                    .background(Color.background.ignoresSafeArea())
                    .edgesIgnoringSafeArea(.bottom)
                    .navigationBarTitle("GLOBAL_TIMELINE", displayMode: .inline)
                    .overlay(overlayFloatButton)
,
                
                tag: Page.timeline,
                selection: Binding($page),
                label: { Label("GLOBAL_TIMELINE", systemImage: "rectangle.grid.1x2.fill") })

            NavigationLink(
                destination:
                    WanderView(showCreatePost: .constant(false), viewModel: wanderViewModel)
                    .background(Color.background.ignoresSafeArea())
                    .edgesIgnoringSafeArea(.bottom)
                    .navigationBarTitle("GLOBAL_WANDER", displayMode: .inline)
                    .overlay(overlayFloatButton),
                tag: Page.wander,
                selection: Binding($page),
                label: { Label("GLOBAL_WANDER", systemImage: "rectangle.3.offgrid.fill") })
        }
        .accentColor(.hollowContentVoteGradient1)
    }
    
    @ViewBuilder var contentSection: some View {
        Text("IPAD_SIDEBAR_CONTENT_SECTION_TITLE").font(.headline)
            .foregroundColor(.secondary)
        NavigationLink(
            destination:
                SearchView(presented: .constant(true), store: .init(type: .search, options: [.unordered]))
                .navigationBarTitle("IPAD_SIDEBAR_SEARCH", displayMode: .inline),
            tag: Page.search,
            selection: Binding($page),
            label: { Label("IPAD_SIDEBAR_SEARCH", systemImage: "magnifyingglass") }
        )
        .accentColor(.hollowContentVoteGradient2)
        
        NavigationLink(
            destination:
                SearchView(presented: .constant(true), store: .init(type: .searchTrending, options: [.unordered]))
                .navigationBarTitle("IPAD_SIDEBAR_TRENDING", displayMode: .inline),
            tag: Page.trending,
            selection: Binding($page),
            label: { Label("IPAD_SIDEBAR_TRENDING", systemImage: "flame") }
        )
        .accentColor(.hollowContentVoteGradient1)
        
        NavigationLink(
            destination: FavouritesView_iPad(),
            tag: Page.favourites,
            selection: Binding($page),
            label: { Label("IPAD_SIDEBAR_FAVOURITES", systemImage: "star") }
        )
        .accentColor(.hollowContentVoteGradient1)
        
        NavigationLink(
            destination:
                MessageView.SystemMessageView(messageStore: MessageStore())
                .navigationBarTitle("IPAD_SIDEBAR_MESSAGES", displayMode: .inline)
                .padding(.leading)
                .edgesIgnoringSafeArea(.bottom)
                .background(Color.background.ignoresSafeArea()),
            tag: Page.notifications,
            selection: Binding($page),
            label: { Label("IPAD_SIDEBAR_MESSAGES", systemImage: "bell") }
        )
        .accentColor(.hollowContentVoteGradient1)
    }
    
    @ViewBuilder var infoSection: some View {
        Text("IPAD_SIDEBAR_INFO_SECTION_TITLE").font(.headline)
            .foregroundColor(.secondary)
        NavigationLink(
            destination:
                AccountInfoView()
                .edgesIgnoringSafeArea(.bottom)
                .navigationViewStyle(StackNavigationViewStyle()),
            tag: Page.account,
            selection: Binding($page),
            label: { Label("ACCOUNTVIEW_ACCOUNT_CELL", systemImage: "person") }
        )
        
        NavigationLink(
            destination:
                SettingsView(presented: .constant(true))
                .edgesIgnoringSafeArea(.bottom)
                .navigationViewStyle(StackNavigationViewStyle()),
            tag: Page.settings,
            selection: Binding($page),
            label: { Label("SETTINGSVIEW_NAV_TITLE", systemImage: "gearshape") }
        )
        
        NavigationLink(
            destination:
                AboutView()
                .edgesIgnoringSafeArea(.bottom)
                .navigationViewStyle(StackNavigationViewStyle()),
            tag: Page.about,
            selection: Binding($page),
            label: { Label("ACCOUNTVIEW_ABOUT_CELL", systemImage: "info.circle") }
        )
        
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
