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
    let transitionAnimation = Animation.defaultSpring
    
    @Namespace var animation
    
    @Default(.searchHistory) var searchHistory
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL

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
                    CustomList(didScrollToBottom: store.loadMorePosts) {
                        PostListView(
                            postDataWrappers: $store.posts,
                            detailStore: $detailStore,
                            revealFoldedTags: store.type != .searchTrending,
                            voteHandler: store.vote,
                            starHandler: store.star,
                            imageReloadHandler: { _ in store.fetchImages() }
                        )
                            .defaultPadding(.horizontal)
                    }
//                    .defaultPadding(.horizontal)
                    .proposedIgnoringSafeArea(edges: .bottom)
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
        .proposedIgnoringSafeArea(edges: .bottom)
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
