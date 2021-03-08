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
    @ObservedObject var store: PostListRequestStore
    @State var startPickerPresented = false
    @State var endPickerPresented = false
    @State var detailPresentedIndex: Int?
    @State var detailStore: HollowDetailStore? = nil

    @State var showPost = false
    var showAdvancedOptions = true
    let transitionAnimation = Animation.searchViewTransition
    
    @Namespace var animation
    
    @Default(.searchHistory) var searchHistory
    @Environment(\.colorScheme) var colorScheme
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
                    searchConfigurationView()

                }
            }
            .padding(.horizontal)
            .padding(.horizontal)
            
            
            if showPost {
                if store.posts.count == 0 && !store.isLoading {
                    Text("SEARCHVIEW_NO_RESULT_LABEL")
                        .foregroundColor(.hollowContentText)
                        .verticalCenter()
                } else {
                    CustomScrollView(didScrollToBottom: store.loadMorePosts) { proxy in
                        LazyVStack(spacing: 0) {
                            PostListView(postDataWrappers: $store.posts, detailStore: $detailStore, revealFoldedTags: store.type != .searchTrending, voteHandler: store.vote, starHandler: store.star)
                        }
                        .padding(.top)
                    }
                    .padding(.horizontal)
                    .ignoresSafeArea()
                    .modifier(LoadingIndicator(isLoading: store.isLoading))
                }
            } else {
                Spacer()
            }
        }
        .defaultBlurBackground(hasPost: showPost)
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
        .modifier(ErrorAlert(errorMessage: $store.errorMessage))
        .onAppear {
            if store.type == .searchTrending { showPost = true }
        }
    }
}
