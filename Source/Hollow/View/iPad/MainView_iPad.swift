//
//  MainView_iPad.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

struct MainView_iPad: View {
    @State var page: Page = .timeline
    @State var showCreatePost = false
    
    // Initialize time line view model here to avoid creating repeatedly
    let timelineViewModel = PostListRequestStore(type: .postList)
    // Initialize wander view model here to avoid creating repeatedly
    let wanderViewModel = PostListRequestStore(type: .wander, options: [.ignoreCitedPost, .ignoreComments, .unordered])

    var body: some View {
        NavigationView {
            List {
                topSection
                contentSection
                infoSection
            }
            .listStyle(SidebarListStyle())
            .navigationTitle(Defaults[.hollowConfig]?.name ?? Constants.Application.appLocalizedName)
        }
        .accentColor(Color.hollowContentVoteGradient1)
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        
        .overlay(Group { if showCreatePost {
            HollowInputView(inputStore: HollowInputStore(presented: $showCreatePost, refreshHandler: {
                page = .timeline
                timelineViewModel.refresh(finshHandler: {})
            }))
            .transition(.move(edge: .bottom))
        }})

        .environment(\.horizontalSizeClass, .regular)
        
    }
}

extension MainView_iPad {
    enum Page: Int, Hashable {
        case timeline
        case wander
        case trending
        case notifications
        case favourites
        case settings
        case account
        case about
        case provider
        case search
    }
}
