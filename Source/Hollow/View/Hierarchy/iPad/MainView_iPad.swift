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
    
    @ObservedObject var sharedModel = SharedModel()
    
    @ScaledMetric(wrappedValue: 40) var rowHeight: CGFloat
    
    @Environment(\.colorScheme) var colorScheme
    
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
                            // We need NavigationLink to keep the items highlighted
                            // when selected. And we need to prevent them pushing
                            // their destination views in the navigation controller.
                            NavigationLink(
                                destination: EmptyView(),
                                tag: page.rawValue,
                                selection: Binding(get: { page.rawValue }, set: {
                                    if let rawValue = $0,
                                       let page = Page(rawValue: rawValue) {
                                        sharedModel.page = page
                                    }
                                }),
                                label: {
                                    Label(page.info.name, systemImage: page.info.imageName)
                                })
                                .accentColor(.hollowContentVoteGradient1)
                        }
                    }
                }
            }
            .conditionalTint(ios: .hollowContentVoteGradient1, mac: colorScheme == .dark ? .uiColor(.secondarySystemFill) : .hollowContentVoteGradient1)
            .conditionalRowHeight(rowHeight)
            .listStyle(SidebarListStyle())
            .navigationTitle(Defaults[.hollowConfig]?.name ?? Constants.Application.appLocalizedName)
        },
        secondaryView: { _ in secondaryView },
        modifiers: { splitVC in
            IntegrationUtilities.topSplitVC = splitVC
            // Temperarily set to oneBesideSecondary first to ensure that we can
            // navigate back to the root vc in onAppear to avoid the additional
            // navigation destinations
            splitVC.preferredDisplayMode = .oneBesideSecondary
            // Apply blur background in mac
            splitVC.primaryBackgroundStyle = .sidebar
            splitVC.primaryController.view.backgroundColor = nil
            splitVC.primaryController.navigationController?.navigationBar.prefersLargeTitles = true
            splitVC.secondaryController.navigationController?.navigationBar.isTranslucent = true
            splitVC.primaryController.navigationController?.navigationBar.tintColor = UIColor(.hollowContentVoteGradient1)
            splitVC.secondaryController.navigationController?.navigationBar.tintColor = UIColor(.tint)
            splitVC.primaryController.navigationController?.delegate = sharedModel
        })
        .ignoresSafeArea()
        
        .onChange(of: sharedModel.page) { _ in
            if let navVC = IntegrationUtilities.getSecondaryNavigationVC() {
                navVC.popToRootViewController(animated: true)
            }
        }
        
        .onAppear {
            #if targetEnvironment(macCatalyst)
            let titleBar = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.titlebar
            titleBar?.titleVisibility = .hidden
            titleBar?.toolbar = nil
            #endif
            guard let splitVC = IntegrationUtilities.topSplitVC else { return }
            if let primaryNavVC = splitVC.viewController(for: .primary)?.parent as? UINavigationController {
                DispatchQueue.main.async {
                    primaryNavVC.popToRootViewController(animated: false)
                    splitVC.preferredDisplayMode = .automatic
                }
            }
        }

        .overlay(Group { if sharedModel.showCreatePost {
            HollowInputView(inputStore: HollowInputStore(presented: $sharedModel.showCreatePost, refreshHandler: {
                page = .timeline
                sharedModel.timelineViewModel.refresh(finshHandler: {})
            }))
            .transition(.move(edge: .bottom))
        }})
        
        .environment(\.horizontalSizeClass, .regular)
    }
    
    class SharedModel: NSObject, ObservableObject, UINavigationControllerDelegate {
        @Published var page: MainView_iPad.Page = .timeline
        @Published var showCreatePost = false
        // Toggle this to force update the view controller
        @Published var shouldUpdate = false
        // Initialize time line view model here to avoid creating repeatedly
        let timelineViewModel = PostListRequestStore(type: .postList, options: .lazyLoad)
        // Initialize wander view model here to avoid creating repeatedly
        let wanderViewModel = PostListRequestStore(type: .wander, options: [.ignoreCitedPost, .ignoreComments, .unordered, .lazyLoad])
        let messageStore = MessageStore(lazyLoad: true)
        let searchTrendingStore = PostListRequestStore(type: .searchTrending, options: [.unordered, .lazyLoad])
        let searchStore = PostListRequestStore(type: .search, options: [.unordered, .lazyLoad])
        let favouriteStore = PostListRequestStore(type: .attentionList, options: .lazyLoad)
        
        func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
            // Never! let! it! push!
            navigationController.popToRootViewController(animated: false)
        }
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

private extension View {
    func conditionalTint(ios: Color, mac: Color) -> some View {
        #if targetEnvironment(macCatalyst)
        return self.accentColor(mac)
        #else
        return self.accentColor(ios)
        #endif
    }
    
    func conditionalRowHeight(_ height: CGFloat) -> some View {
        #if targetEnvironment(macCatalyst)
        return self.environment(\.defaultMinListRowHeight, height)
        #else
        return self
        #endif
    }
}
