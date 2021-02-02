//
//  MainView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/17.
//

import SwiftUI

struct MainView: View {
    @State private var page: Page = .timeline
    @State private var isSearching = false
    
    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            VStack(spacing: 12) {
                HeaderView(page: $page, isSearching: $isSearching)
                    .padding(.horizontal)
                    .padding(.top, 10)
                // We use our modified TabView to avoid default background color when using
                // `CustomScrollView` in `TabView`, but be careful that this trick could fail in
                // future updates.
                CustomTabView(selection: $page, ignoreSafeAreaEdges: .bottom) {
                    WanderView()
                        .tag(Page.wander)
                    TimelineView(isSearching: $isSearching)
                        .tag(Page.timeline)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .overlay(
            Group {
                if isSearching {
                    SearchView(presented: $isSearching)
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
        var body: some View {
            HStack(spacing: 2) {
                Group {
                    Button(action: {
                        withAnimation {
                            page = .wander
                        }
                    }) {
                        Text(String.wanderCapitalized)
                            .mainTabText(selected: page == .wander)
                            .animation(.spring())
                    }
                    .disabled(page == .wander)
                    Text("/")
                        .mainTabText(selected: true)
                        .rotationEffect(.init(degrees: page == .wander ? 360 : 0))
                        .animation(.spring())
                    Button(action: {
                        withAnimation {
                            page = .timeline
                        }
                    }) {
                        Text(String.timelineCapitalized)
                            .mainTabText(selected: page == .timeline)
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
                    Button(action:{}) {
                        Image(systemName: "person")
                            .padding(.leading, 7)
                    }
                }
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.mainBarButton)
            }

        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
//            .colorScheme(.dark)
    }
}
