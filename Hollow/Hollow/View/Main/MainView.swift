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
            Group { if isSearching {
                SearchView(presented: $isSearching)
            }}
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
        @State private var accountPresented = false
        
        @ScaledMetric(wrappedValue: 20, relativeTo: .body) var body20: CGFloat
        @ScaledMetric(wrappedValue: 22, relativeTo: .body) var body22: CGFloat
        @ScaledMetric(wrappedValue: 18, relativeTo: .body) var body18: CGFloat

        var body: some View {
            HStack(spacing: 2) {
                Group {
                    Button(action: { withAnimation { page = .wander }}) {
                        mainTabText(text: String.wanderLocalized.capitalized, selected: page == .wander)
                            .animation(.spring())
                    }
                    .disabled(page == .wander)
                    mainTabText(text: "/", selected: true)
                        .rotationEffect(.init(degrees: page == .wander ? 360 : 0))
                        .animation(.spring())
                    Button(action: { withAnimation { page = .timeline }}) {
                        mainTabText(text: String.timelineLocalized.capitalized, selected: page == .timeline)
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
                .font(.system(size: body20, weight: .medium))
                .foregroundColor(.mainBarButton)
            }
            .sheet(isPresented: $accountPresented, content: {
                AccountView(presented: $accountPresented)
            })

        }
        
        private func mainTabText(text: String, selected: Bool) -> some View {
            return Text(text)
                .fontWeight(.heavy)
                .font(.system(size: selected ? body22 : body18))
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
