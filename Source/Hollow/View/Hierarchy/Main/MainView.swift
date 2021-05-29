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
    @State private var showTrending = false
    @State private var showCreatePost = false
    @State private var showMessage = false
    
    // Initialize time line view model here to avoid creating repeatedly
    let timelineViewModel = PostListRequestStore(type: .postList)
    // Initialize wander view model here to avoid creating repeatedly
    let wanderViewModel = PostListRequestStore(type: .wander, options: [.ignoreCitedPost, .ignoreComments, .unordered])
    
    let overlayTransition = AnyTransition.asymmetric(insertion: .opacity, removal: .scaleAndOpacity)
    @Namespace var namespace
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            VStack(spacing: 12) {
                HeaderView(page: $page, isSearching: $isSearching, showTrending: $showTrending, showMessage: $showMessage, namespace: namespace)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .zIndex(2)
                
                // Use our modified TabView to avoid default background color when using
                // `CustomScrollView` in `TabView`
                CustomTabView(selection: $page, ignoreSafeAreaEdges: .bottom) {
                    WanderView(
                        showCreatePost: $showCreatePost,
                        viewModel: wanderViewModel
                    )
                    .tag(Page.wander)
                    TimelineView(
                        isSearching: $isSearching,
                        viewModel: timelineViewModel
                    )
                    .tag(Page.timeline)
                }
                
                // Overlay circular buttons
                .overlay(
                    Group { if !showCreatePost {
                        FloatButton(
                            action: {
                                withAnimation(.defaultSpring) { showCreatePost = true }
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            },
                            systemImageName: "plus",
                            buttonAnimationNamespace: namespace
                        )
                        .bottom()
                        .trailing()
                        .padding()
                        .padding(5)
                        .padding(.bottom, 5)
                    }}
                )
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .proposedOverlay()

        .overlay(Group {
            if showCreatePost {
                Color.black.opacity(colorScheme == .dark ? 0.2 : 0.1).ignoresSafeArea()
            }
        })
        .overlay(
            Group {
                if isSearching {
                    SearchView(presented: $isSearching, store: .init(type: .search, options: [.unordered]))
                        .swipeToDismiss(presented: $isSearching, transition: .hide(to: .init(x: 0.8, y: 0.1)))
                }
                if showCreatePost {
                    HollowInputView(inputStore: HollowInputStore(presented: $showCreatePost, refreshHandler: {
                        timelineViewModel.refresh(finshHandler: {})
                    }), buttonAnimationNamespace: namespace)
                    .swipeToDismiss(presented: $showCreatePost, transition: .floatButton)
                }
                if showTrending {
                    SearchView(presented: $showTrending, store: .init(type: .searchTrending, options: [.unordered]))
                        .matchedGeometryEffect(id: "trending", in: namespace)
                        .swipeToDismiss(presented: $showTrending, transition: overlayTransition)
                }
                
                if showMessage {
                    MessageView(presented: $showMessage)
                        .matchedGeometryEffect(id: "message", in: namespace)
                        .swipeToDismiss(presented: $showMessage, transition: overlayTransition)
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
    private struct HeaderView: View {
        @Binding var page: MainView.Page
        @Binding var isSearching: Bool
        @Binding var showTrending: Bool
        @Binding var showMessage: Bool

        @State private var accountPresented = false
        
        let namespace: Namespace.ID

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
                    Button(action: { withAnimation { showTrending = true } }) {
                        Image(systemName: "flame")
                            .padding(.horizontal, 10)
                    }
                    .withPlaceholder(showTrending, namespace: namespace, id: "trending")

                    Button(action:{ withAnimation { showMessage = true } }) {
                        Image(systemName: "bell")
                            .padding(.horizontal, 7)
                    }
                    .withPlaceholder(showMessage, namespace: namespace, id: "message")

                    Button(action:{
                        accountPresented = true
                    }) {
                        Image(systemName: "person")
                            .padding(.leading, 7)
                    }
                }
                .dynamicFont(size: 20, weight: .medium)
                .foregroundColor(.hollowContentText)
            }
            .fullScreenCover(isPresented: $accountPresented, content: {
                NavigationView {
                    SettingsView(presented: $accountPresented)
                }
                .accentColor(.tint)
            })

        }
        
        private func mainTabText(text: String, selected: Bool) -> some View {
            return Text(text)
                .fontWeight(.heavy)
                .dynamicFont(size: selected ? 22 : 18)
                .foregroundColor(selected ? .hollowContentText : .mainPageUnselected)
                .lineLimit(1)
        }
    }
}
