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

    var body: some View {
        VStack {
            if !UIDevice.isPad {
                topBar()
                    .padding(.horizontal)
            }

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
                        .horizontalCenter()
                } else {
                    CustomScrollView(didScrollToBottom: store.loadMorePosts) { proxy in
                        LazyVStack(spacing: 0) {
                            PostListView(postDataWrappers: $store.posts, detailStore: $detailStore, revealFoldedTags: store.type != .searchTrending, voteHandler: store.vote, starHandler: store.star)
                        }
                        .padding(.top)
                    }
                    .defaultPadding(.horizontal)
                    .edgesIgnoringSafeArea(.bottom)
                    .modifier(LoadingIndicator(isLoading: store.isLoading))
                }
            } else {
                Spacer()
            }
        }
        .padding(UIDevice.isMac && !showPost ? ViewConstants.macAdditionalPadding : 0)
        .background(Group { if UIDevice.isPad {
            Color.background.ignoresSafeArea()
        }})
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
        
        // iPad
        .navigationBarItems(leading: Group { if showPost && store.type != .searchTrending {
            closeButton
        }}, trailing: Group { if !showPost || store.type == .searchTrending {
            searchButton
        }})
    }
}
