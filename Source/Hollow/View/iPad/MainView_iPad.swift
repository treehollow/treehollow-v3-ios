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
    
    @ObservedObject var sharedModel = SharedModel()
    
    var body: some View {
        SplitView(sharedModel: sharedModel, primaryView: { _ in
            List {
                ForEach(Page.Section.allCases) { section in
                    if let title = section.title {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    ForEach(Page.allCases) { page in
                        
                        if page.section == section {
                            Button(action: {
                                sharedModel.page = page
                            }) {
                                Label(page.info.name, systemImage: page.info.imageName)
                            }
                            .accentColor(.hollowContentVoteGradient1)
                        }
                    }
                }
            }
            .accentColor(.hollowContentVoteGradient1)
            .listStyle(SidebarListStyle())
            .navigationTitle(Defaults[.hollowConfig]?.name ?? Constants.Application.appLocalizedName)
        },
        secondaryView: { _ in secondaryView },
        modifiers: { splitVC in
            IntegrationUtilities.topSplitVC = splitVC
            splitVC.primaryController.navigationController?.navigationBar.prefersLargeTitles = true
            splitVC.secondaryController.navigationController?.navigationBar.isTranslucent = true
            splitVC.primaryController.navigationController?.navigationBar.tintColor = UIColor(.tint)
            splitVC.secondaryController.navigationController?.navigationBar.tintColor = UIColor(.tint)
        })
        .ignoresSafeArea()
        
        .onChange(of: sharedModel.page) { _ in
            guard let navVC = IntegrationUtilities.getSecondaryNavigationVC() else { return }
            navVC.popToRootViewController(animated: true)
        }

        .overlay(Group { if showCreatePost {
            HollowInputView(inputStore: HollowInputStore(presented: $showCreatePost, refreshHandler: {
                page = .timeline
                sharedModel.timelineViewModel.refresh(finshHandler: {})
            }))
            .transition(.move(edge: .bottom))
        }})

        .environment(\.horizontalSizeClass, .regular)
        
    }
    
    class SharedModel: ObservableObject {
        @Published var page: MainView_iPad.Page = .timeline
        // Initialize time line view model here to avoid creating repeatedly
        let timelineViewModel = PostListRequestStore(type: .postList)
        // Initialize wander view model here to avoid creating repeatedly
        let wanderViewModel = PostListRequestStore(type: .wander, options: [.ignoreCitedPost, .ignoreComments, .unordered])
    }
}

extension MainView_iPad {
    enum Page: Int, Hashable, CaseIterable, Identifiable {
        case timeline
        case wander
        case search
        case trending
        case favourites
        case notifications
        case account
        case settings
        case about
        
        var id: Int { rawValue }

        
        enum Section: Int, Hashable, CaseIterable, Identifiable {
            case main, content, info
            var id: Int { rawValue }
            var title: String? {
                switch self {
                case .main: return nil
                case .content:
                    return NSLocalizedString("IPAD_SIDEBAR_CONTENT_SECTION_TITLE", comment: "")
                case .info:
                    return NSLocalizedString("IPAD_SIDEBAR_INFO_SECTION_TITLE", comment: "")
                }
            }
        }
        
        var info: (name: String, imageName: String) {
            switch self {
            case .timeline:
                return (NSLocalizedString("GLOBAL_TIMELINE", comment: ""), "rectangle.grid.1x2.fill")
            case .wander:
                return (NSLocalizedString("GLOBAL_WANDER", comment: ""), "rectangle.3.offgrid.fill")
            case .search:
                return (NSLocalizedString("IPAD_SIDEBAR_SEARCH", comment: ""), "magnifyingglass")
            case .trending:
                return (NSLocalizedString("IPAD_SIDEBAR_TRENDING", comment: ""), "flame")
            case .favourites:
                return (NSLocalizedString("IPAD_SIDEBAR_FAVOURITES", comment: ""), "star")
            case .notifications:
                return (NSLocalizedString("IPAD_SIDEBAR_MESSAGES", comment: ""), "bell")
            case .account:
                return (NSLocalizedString("ACCOUNTVIEW_ACCOUNT_CELL", comment: ""), "person")
            case .settings:
                return (NSLocalizedString("SETTINGSVIEW_NAV_TITLE", comment: ""), "gearshape")
            case .about:
                return (NSLocalizedString("ACCOUNTVIEW_ABOUT_CELL", comment: ""), "info.circle")
            }
        }
        
        var section: Section {
            switch self {
            case .wander, .timeline: return .main
            case .search, .trending, .favourites, .notifications: return .content
            case .account, .settings, .about: return .info
            }
        }
    }
}
