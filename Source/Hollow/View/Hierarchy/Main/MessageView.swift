//
//  MessageView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct MessageView: View {
    @Binding var presented: Bool
    @State var page: Page = .attention
    @ObservedObject var messageStore = MessageStore()
    @ObservedObject var postListStore = PostListRequestStore(type: .attentionList)
    @State private var isSearching = false
    
    var selfDismiss = false
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            topBar
            CustomTabView(selection: $page, ignoreSafeAreaEdges: .bottom) {
                AttentionListView(postListStore: postListStore, isSearching: $isSearching)
                    .tag(Page.attention)
                SystemMessageView(messageStore: messageStore)
                    .tag(Page.message)
            }
            .ignoresSafeArea()
            // To avoid conflict with swipe gesture
            .padding(.leading)
        }
        .defaultBlurBackground(hasPost: true)
        .overlay(Group { if isSearching {
            SearchView(
                presented: $isSearching,
                store: .init(type: .attentionListSearch, options: [.unordered]),
                showAdvancedOptions: false
            )
        }})
    }
}

extension MessageView {
    var topBar: some View {
        HStack {
            Button(action: {
                if selfDismiss { dismissSelf() }
                else {
                    withAnimation { presented = false }
                }
            }) {
                Image(systemName: "xmark")
                    .modifier(ImageButtonModifier())
                    .padding(.trailing)
            }
            Picker("", selection: $page) {
                Text(NSLocalizedString("MESSAGEVIEW_PICKER_ATTENTION", comment: ""))
                    .tag(Page.attention)
                Text(NSLocalizedString("MESSAGEVIEW_PICKER_MESSAGE", comment: ""))
                    .tag(Page.message)
            }
            .padding(.horizontal)
            .pickerStyle(SegmentedPickerStyle())
            Spacer()
        }
        .padding(.horizontal)
        .topBar()
        .padding(.vertical, 5)

    }
}

extension MessageView {
    struct AttentionListView: View {
        @ObservedObject var postListStore: PostListRequestStore
        @Binding var isSearching: Bool
        @State var detailStore: HollowDetailStore?

        var body: some View {
            CustomScrollView(
                didScrollToBottom: postListStore.loadMorePosts,
                refresh: postListStore.refresh
            ) { proxy in
                LazyVStack(spacing: 0) {
                    SearchBar(isSearching: $isSearching)
                        .padding(.bottom)

                    PostListView(
                        postDataWrappers: $postListStore.posts,
                        detailStore: $detailStore,
                        voteHandler: postListStore.vote,
                        starHandler: postListStore.star,
                        imageReloadHandler: { _ in postListStore.fetchImages() }
                    )
                }
            }
            .padding(.trailing)
            .modifier(LoadingIndicator(isLoading: postListStore.isLoading))
            .modifier(ErrorAlert(errorMessage: $postListStore.errorMessage))
        }
    }
    
    struct SystemMessageView: View {
        @ObservedObject var messageStore: MessageStore
        var body: some View {
            CustomScrollView(refresh: messageStore.requestMessages) { proxy in VStack(spacing: 0) {
                ForEach(messageStore.messages) { message in
                    LazyVStack(alignment: .leading) {
                        HStack {
                            Text(message.title)
                                .bold()
                                .foregroundColor(.hollowContentText)
                                .dynamicFont(size: 16)
                            Spacer()
                            Text.dateText(message.date)
                                .foregroundColor(.secondary)
                                .font(.footnote)
                        }
                        .padding(.bottom, 7)
                        Text(message.content)
                            .dynamicFont(size: 15)
                    }
                    .padding()
                    .background(Color.hollowCardBackground)
                    .roundedCorner(15)
                }
                .padding(.top)
            }}
            .padding(.trailing)
            .modifier(ErrorAlert(errorMessage: $messageStore.errorMessage))
            .modifier(LoadingIndicator(isLoading: messageStore.isLoading))
        }
    }
}

extension MessageView {
    enum Page: Int, Hashable { case message, attention }
}
