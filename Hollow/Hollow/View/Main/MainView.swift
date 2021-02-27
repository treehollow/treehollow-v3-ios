//
//  MainView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/17.
//

import SwiftUI

/// View for the main interface.
struct MainView: View {
    /// Define `TabView` state.
    @State private var page: Page = .timeline
    @State private var isSearching = false
    @State private var showCreatePost = false
    /// Whether to show the overlay refresh button.
    ///
    /// The value is determined by the current nested view.
    @State private var showRefresh = false
    /// Whether the nested `TimelineView` should reload.
    @State private var shouldReloadTimeline = false
    /// Whether the nested `WanderView` should reload.
    @State private var shouldReloadWander = false
    
    @ScaledMetric(wrappedValue: 30, relativeTo: .body) var body30: CGFloat
    @ScaledMetric(wrappedValue: 50, relativeTo: .body) var body50: CGFloat
    
    @Namespace var animation
    
    // Initialize time line view model here to avoid creating repeatedly
    let timelineViewModel = PostListRequestStore(type: .postList)
    // Initialize wander view model here to avoid creating repeatedly
    let wanderViewModel = PostListRequestStore(type: .wander, options: [.ignoreCitedPost, .ignoreComments, .unordered])

    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            VStack(spacing: 12) {
                HeaderView(page: $page, isSearching: $isSearching)
                    .padding(.horizontal)
                    .padding(.top, 10)
//                    .padding(.vertical, UIDevice.current.userInterfaceIdiom == .pad ? 3 : 0)
                
                // Use our modified TabView to avoid default background color when using
                // `CustomScrollView` in `TabView`
                CustomTabView(selection: $page, ignoreSafeAreaEdges: .bottom) {
                    WanderView(
                        showCreatePost: $showCreatePost,
                        showReload: $showRefresh,
                        shouldReload: $shouldReloadWander,
                        viewModel: wanderViewModel
                    )
                        .tag(Page.wander)
                    TimelineView(
                        isSearching: $isSearching,
                        showReload: $showRefresh,
                        shouldReload: $shouldReloadTimeline,
                        viewModel: timelineViewModel
                    )
                    .tag(Page.timeline)
                }
                
                // Overlay circular buttons
                .overlay(
                    VStack {
                        if !showCreatePost {
                            button(
                                action: {
                                    withAnimation { showCreatePost = true }
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                },
                                systemName: "plus"
                            )
                            .matchedGeometryEffect(id: "add.post", in: animation)
                        }
                        if showRefresh {
                            button(
                                action: { withAnimation {
                                        switch page {
                                        case .timeline: shouldReloadTimeline = true
                                        case .wander: shouldReloadWander = true
                                        }
                                }},
                                systemName: "arrow.clockwise"
                            )
                            .padding(.top, 5)
                        }
                    }
                    .bottom()
                    .trailing()
                    .padding()
                    .padding(5)
                    .padding(.bottom, 5)
                )
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .overlay(
            Group {
                if isSearching {
                    SearchView(presented: $isSearching)
                }
                if showCreatePost {
                    HollowInputView(inputStore: HollowInputStore(presented: $showCreatePost))
                        .matchedGeometryEffect(id: "add.post", in: animation)
                }
            }
        )
    }
    
    enum Page: Int, Identifiable {
        var id: Int { return rawValue }
        
        case wander
        case timeline
    }
}

extension MainView {
    func button(action: @escaping () -> Void, systemName: String) -> some View {
        Button(action: action) {
            ZStack {
                LinearGradient.vertical(gradient: .hollowContentVote)
                Image(systemName: systemName)
                    .font(.system(size: body30))
                    .foregroundColor(.white)
            }
        }
        .frame(width: body50, height: body50)
        .clipShape(Circle())
    }
    
    private struct HeaderView: View {
        @Binding var page: MainView.Page
        @Binding var isSearching: Bool
        @State private var accountPresented = false
        
        // iPhone
        @ScaledMetric(wrappedValue: 20, relativeTo: .body) var iconSize: CGFloat
        @ScaledMetric(wrappedValue: 22, relativeTo: .body) var tabSelectedSize: CGFloat
        @ScaledMetric(wrappedValue: 18, relativeTo: .body) var tabUnselectedSize: CGFloat

        var body: some View {
            HStack(spacing: 2) {
                Group {
                    Button(action: { withAnimation { page = .wander }}) {
                        mainTabText(text: NSLocalizedString("GLOBAL_WANDER", comment: ""), selected: page == .wander)
                            .animation(.spring())
                    }
                    .disabled(page == .wander)
                    mainTabText(text: "/", selected: true)
                        .rotationEffect(.init(degrees: page == .wander ? 360 : 0))
                        .animation(.spring())
                    Button(action: { withAnimation { page = .timeline }}) {
                        mainTabText(text: NSLocalizedString("GLOBAL_TIMELINE", comment: ""), selected: page == .timeline)
                            .animation(.spring())
                    }
                    .disabled(page == .timeline)
                }
                .layoutPriority(1)
                Spacer()
                Group {
                    Button(action:{}) {
                        Image(systemName: "flame")
                            .padding(.horizontal, 10)
                    }
                    Button(action:{}) {
                        // TODO: bell.badge
                        Image(systemName: "bell")
                            .padding(.horizontal, 7)
                    }
                    Button(action:{
                        accountPresented = true
                    }) {
                        Image(systemName: "person")
                            .padding(.leading, 7)
                    }
                }
                .font(.system(size: iconSize, weight: .medium))
                .foregroundColor(.mainBarButton)
            }
            .sheet(isPresented: $accountPresented, content: {
                AccountView(presented: $accountPresented)
            })

        }
        
        private func mainTabText(text: String, selected: Bool) -> some View {
            return Text(text)
                .fontWeight(.heavy)
                .font(.system(size: selected ? tabSelectedSize : tabUnselectedSize))
                .foregroundColor(selected ? .mainPageSelected : .mainPageUnselected)
                .lineLimit(1)
        }
    }
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
//            .colorScheme(.dark)
    }
}
#endif
