//
//  HollowDetailView_iPad.swift
//  Hollow
//
//  Created by liang2kl on 2021/3/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct HollowDetailView_iPad: View {
    @ObservedObject var store: HollowDetailStore
    
    @ScaledMetric(wrappedValue: 33, relativeTo: .body) var avatarWidth: CGFloat
    @ScaledMetric(wrappedValue: 17, relativeTo: .body) var body17: CGFloat
    
    var body: some View {
        HollowDetailView(store: store, showHeader: false)
            .navigationTitle(Text(store.postDataWrapper.post.text.removeLineBreak()))
            .navigationBarItems(
                leading:
                    HStack(spacing: 10) {
                        let postData = store.postDataWrapper.post
                        let tintColor = ViewConstants.avatarTintColors[postData.colorIndex]
                        Avatar(
                            foregroundColor: tintColor,
                            backgroundColor: .white,
                            resolution: 6,
                            padding: avatarWidth * 0.1,
                            hashValue: postData.hash,
                            name: String(store.postDataWrapper.post.postId.string.last ?? " ")
                        )
                        // Scale the avatar relative to the font scaling.
                        .frame(width: avatarWidth, height: avatarWidth)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(lineWidth: 2).foregroundColor(tintColor))
                        
                        VStack(alignment: .leading) {
                            Text("#\(postData.postId.string)")
                                .foregroundColor(.hollowContentText)
                            Text.dateText(postData.timestamp)
                                .fontWeight(.semibold)
                                .font(.footnote)
                                .foregroundColor(.hollowCardStarUnselected)
                        }
                        .leading()
                    }
                    .padding(.trailing),

                trailing: HStack {
                    
                    let postData = store.postDataWrapper.post
                    
                    if store.isLoading {
                        Spinner(color: .hollowCardStarUnselected, desiredWidth: body17)
                    } else {
                        let attention = postData.attention
                        Button(action: { store.star(!attention) }) {
                            HStack(spacing: 3) {
                                Text("\(postData.likeNumber)")
                                Image(systemName: attention ? "star.fill" : "star")
                            }
                            .modifier(HollowButtonStyle())
                            .padding(.vertical, 5)
                            .foregroundColor(attention ? .hollowCardStarSelected : .hollowCardStarUnselected)
                        }
                        .disabled(store.isEditingAttention || store.noSuchPost)
                    }
                    
                    Menu(content: {
                        Button(action: store.requestDetail) {
                            Label("DETAIL_MENU_REFRESH_LABEL", systemImage: "arrow.clockwise")
                        }
                        .disabled(store.isLoading)
                        
                        Divider()
                        
                        Button(action: {
                            let inputStore = HollowInputStore(presented: .constant(true), selfDismiss: true, refreshHandler: nil)
                            inputStore.text = "#\(postData.postId.string)\n"
                            IntegrationUtilities.presentView(modalInPresentation: true, content: { HollowInputView(inputStore: inputStore) })
                        }) {
                            Label("DETAIL_MENU_QUOTE_LABEL", systemImage: "text.quote")
                        }
                        
                        Divider()
                        ReportMenuContent(
                            store: store,
                            permissions: store.postDataWrapper.post.permissions,
                            commentId: nil
                        )
                        .disabled(store.isLoading)
                        
                    }, label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .frame(width: body17, height: body17)
                            .padding(5)
                            .padding(.vertical, 5)
                            .padding(.leading, 2)
                            .foregroundColor(.hollowCardStarUnselected)
                            .modifier(HollowButtonStyle())
                    })
                    .disabled(store.noSuchPost)
                }
                .padding(.leading)
            )

    }
}
