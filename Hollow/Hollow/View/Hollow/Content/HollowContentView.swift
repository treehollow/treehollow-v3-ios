//
//  HollowContentView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct HollowContentView: View {
    @State private var presentedIndex: Int?
    @State private var detailStore: HollowDetailStore?
    var postDataWrapper: PostDataWrapper
    var compact: Bool
    var voteHandler: (String) -> Void
    // We get this value from the parent.
    var maxImageHeight: CGFloat? = nil
    
    private var hasVote: Bool { postDataWrapper.post.vote != nil }
    private var hasImage: Bool { postDataWrapper.post.hollowImage != nil }

    var body: some View {
        if hasImage {
            HollowImageView(hollowImage: postDataWrapper.post.hollowImage!, description: postDataWrapper.post.text)
                .cornerRadius(4)
                .frame(maxHeight: maxImageHeight)
                .fixedSize(horizontal: false, vertical: true)
        }
        
        if let citedPid = postDataWrapper.citedPostID {
            if let citedPost = postDataWrapper.citedPost, !compact {
                Button(action: {
                    DispatchQueue.main.async {
                        presentedIndex = 1
                    }
                }) {
                    HollowCiteContentView(placeholderPostId: citedPid, postData: postDataWrapper.citedPost)
                }
                .sheet(item: $presentedIndex) { _ in Group {
                    // FIXME: Possibly initializing more than once.
                    HollowDetailView(store: HollowDetailStore(bindingPostWrapper: .constant(.init(post: citedPost, citedPost: nil))), presentedIndex: $presentedIndex)
                }}
            } else {
                HollowCiteContentView(placeholderPostId: citedPid, postData: postDataWrapper.citedPost)
            }
        }
        
        // Enable the context menu for the text if it is in detail view.
        if postDataWrapper.post.text != "" {
            if compact {
                textView()
            } else {
                textView()
                    // Apply a transparent background to avoid
                    // offset when presenting context menu
                    .background(Color.clear)
                    .contextMenu(compact ? nil : ContextMenu(menuItems: {
                        Button("Copy full text", action: {
                            UIPasteboard.general.string = postDataWrapper.post.text
                        })
                    }))
            }
                    
        }
        
        if hasVote {
            HollowVoteContentView(vote: postDataWrapper.post.vote!, voteHandler: voteHandler)
        }

    }
    
    private func textView() -> some View {
        HollowTextView(text: postDataWrapper.post.text, compactLineLimit: compact ? 6 : nil)
    }
}
