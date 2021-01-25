//
//  MainView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/17.
//

import SwiftUI

struct MainView: View {
    @State private var page: Page = .timeline
    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            VStack {
                HeaderView(page: $page)
                    .padding(.horizontal)
                TabView(selection: $page) {
                    Text("Placeholder: Wander")
                        .tag(Page.wander)
                    TimelineView()
                        .edgesIgnoringSafeArea(.bottom)
                        .tag(Page.timeline)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
}

struct HeaderView: View {
    @Binding var page: MainView.Page
    
    var body: some View {
        HStack(spacing: 2) {
            Group {
                Button(action: {
                    page = .wander
                }) {
                    Text(LocalizedStringKey("Wander"))
                        .mainTabText(selected: page == .wander)
                        .animation(.spring())
                }
                .disabled(page == .wander)
                Text(LocalizedStringKey("/"))
                    .mainTabText(selected: true)
                    .rotationEffect(.init(degrees: page == .wander ? 360 : 0))
                    .animation(.spring())
                Button(action: {
                    page = .timeline
                }) {
                    Text(LocalizedStringKey("Timeline"))
                        .mainTabText(selected: page == .timeline)
                        .animation(.spring())
                    
                }
                .disabled(page == .timeline)
            }
            .layoutPriority(1)
            Spacer()
            Button(action:{
                // Navigate to search view
            }) {
                HStack {
                    Text("Search")
//                    Spacer(minLength: 20)
                    Image(systemName: "magnifyingglass")
                }
                .fixedSize()
                .font(.system(size: 12))
                .foregroundColor(.mainSearchBarText)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Capsule().foregroundColor(.mainSearchBarBackground))
                .padding(.trailing, 5)
            }
            Button(action:{}) {
                // TODO: bell.badge
                Image(systemName: "bell")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.mainBarButton)
                    .padding(.horizontal, 5)
            }
            Button(action:{}) {
                Image(systemName: "person")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.mainBarButton)
                    .padding(.horizontal, 5)
            }

        }
    }
}

extension MainView {
    enum Page: Int, Identifiable {
        var id: Int { return rawValue }
        
        case wander
        case timeline
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .colorScheme(.dark)
    }
}
