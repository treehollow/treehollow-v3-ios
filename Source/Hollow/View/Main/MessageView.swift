//
//  MessageView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct MessageView: View {
    @State private var page: Page = .message
    @ObservedObject var messageStore = MessageStore()
    @ObservedObject var postListStore = PostListRequestStore(type: .attentionList)
    @State var detailStore: HollowDetailStore?
    @State private var isSearching = false
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            topBar
            CustomTabView(selection: $page, ignoreSafeAreaEdges: .bottom) {
                systemMessageView
                    .tag(Page.message)
                
                attentionListView
                    .tag(Page.attention)
            }
            .ignoresSafeArea()
        }
        .background(Color.background.ignoresSafeArea())
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
            Button(action: dismissSelf) {
                Image(systemName: "xmark")
                    .modifier(ImageButtonModifier())
                    .padding(.trailing)
            }
            Picker("", selection: $page) {
                Text(NSLocalizedString("MESSAGEVIEW_PICKER_MESSAGE", comment: ""))
                    .tag(Page.message)
                Text(NSLocalizedString("MESSAGEVIEW_PICKER_ATTENTION", comment: ""))
                    .tag(Page.attention)
            }
            .padding(.horizontal)
            .pickerStyle(SegmentedPickerStyle())
            Spacer()
        }
        .padding(.horizontal)
        .topBar()
        .padding(.bottom, 5)

    }
    
    var systemMessageView: some View {
        CustomScrollView(refresh: {_ in}) { proxy in
            ForEach(messageStore.messages) { message in
                VStack(alignment: .leading) {
                    HStack {
                        Text(message.title)
                            .bold()
                        Spacer()
                        Text(HollowDateFormatter(date: message.timestamp).formattedString())
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 7)
                    Text(message.content)
                }
                .padding()
                .background(Color.hollowCardBackground)
                .cornerRadius(15)
                .padding([.horizontal, .bottom])
            }
            .padding(.top)
        }
        .ignoresSafeArea()
        .modifier(ErrorAlert(errorMessage: $messageStore.errorMessage))
        .modifier(AppModelBehaviour(state: messageStore.appModelState))
    }
    
    var attentionListView: some View {
        CustomScrollView(
            didScrollToBottom: postListStore.loadMorePosts,
            refresh: postListStore.refresh
        ) { proxy in
            VStack(spacing: 0) {
                SearchBar(isSearching: $isSearching)
                    .padding(.horizontal)
                    .padding(.bottom)

                PostListView(
                    postDataWrappers: $postListStore.posts,
                    detailStore: $detailStore,
                    voteHandler: postListStore.vote,
                    starHandler: postListStore.star
                )
            }
        }
        .ignoresSafeArea()
        .background(Color.background)
        .modifier(AppModelBehaviour(state: postListStore.appModelState))
        .modifier(LoadingIndicator(isLoading: postListStore.isLoading))
        .modifier(ErrorAlert(errorMessage: $postListStore.errorMessage))
    }
}

extension MessageView {
    enum Page: Int, Hashable { case message, attention }
}
