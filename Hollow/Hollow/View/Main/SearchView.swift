//
//  SearchView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/17.
//

import SwiftUI
import Defaults

struct SearchView: View {
    @Binding var presented: Bool
    @ObservedObject var store = PostListRequestStore(type: .search)
    // TODO: Add other options in Defaults
    @State var showsAdvancedOptions = Defaults[.searchViewShowsAdvanced] {
        didSet { Defaults[.searchViewShowsAdvanced] = showsAdvancedOptions }
    }
    @State var isSearching = false
    @State var startPickerPresented = false
    @State var endPickerPresented = false
    @State var searchText: String = ""
    // TODO: Time constrains
    @State var startDate: Date = .init()
    @State var endDate: Date = .init()
    @State var detailPresentedIndex: Int?
    @State var detailStore: HollowDetailStore? = nil

    let transitionAnimation = Animation.searchViewTransition
    @State var showPost = false
    
    @Namespace var animation
    
    @ScaledMetric(wrappedValue: 16, relativeTo: .body) var body16: CGFloat
    @ScaledMetric(wrappedValue: 10, relativeTo: .body) var body10: CGFloat
    @ScaledMetric(wrappedValue: ViewConstants.plainButtonFontSize) var buttonFontSize: CGFloat
    @ScaledMetric(wrappedValue: 20, relativeTo: .body) var body20: CGFloat

    var body: some View {
        VStack {
            topBar()
                .padding(.horizontal)

            // Group for additional padding
            Group {
                if !showPost {
                    searchField()
                        .padding(.vertical)
                        .matchedGeometryEffect(id: "searchview.searchbar", in: animation)
                    searchConfigurationView()

                }
            }
            .padding(.horizontal)
            .padding(.horizontal)
            
            
            if showPost {
                if store.posts.count == 0 && !store.isLoading {
                    Text("No Result")
                        .foregroundColor(.hollowContentText)
                        .verticalCenter()
                } else {
                    listView().ignoresSafeArea()
                }
            } else {
                Spacer()
            }
        }
        // Background color
        .background(Color.background.opacity(0.4).edgesIgnoringSafeArea(.all))
        // Blur background
        .blurBackground(style: .systemUltraThinMaterial)
        .transition(.move(edge: .bottom))
//        .animation(transitionAnimation)
        .edgesIgnoringSafeArea(.bottom)
        .overlay(
            Group {
                if startPickerPresented {
                    pickerOverlay(isStart: true)
                } else if endPickerPresented {
                    pickerOverlay(isStart: false)
                }
            }
        )
        .sheet(item: $detailPresentedIndex, content: { index in Group {
            if let store = detailStore {
                HollowDetailView(store: store, presentedIndex: $detailPresentedIndex)
            }
        }})
    }
    
    func listView() -> some View {
        CustomScrollView(didScrollToBottom: store.loadMorePosts) { proxy in
            
            HollowTimeilneListView(postDataWrappers: $store.posts, detailStore: $detailStore, detailPresentedIndex: $detailPresentedIndex, voteHandler: store.vote)
                .padding(.top)
        }
        .modifier(LoadingIndicator(isLoading: store.isLoading))
    }
}

#if DEBUG
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
//            .colorScheme(.dark)
    }
}
#endif
