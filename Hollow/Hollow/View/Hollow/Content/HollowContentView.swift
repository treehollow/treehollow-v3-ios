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
    var options: DisplayOptions
    var voteHandler: (String) -> Void
    // We get this value from the parent.
    var maxImageHeight: CGFloat? = nil
    var lineLimit: Int = 12
    
    private var hasVote: Bool { postDataWrapper.post.vote != nil }
    private var hasImage: Bool { postDataWrapper.post.hollowImage != nil }

    var body: some View {
        if hasImage && options.contains(.displayImage) {
            HollowImageView(hollowImage: postDataWrapper.post.hollowImage!, description: postDataWrapper.post.text)
                .cornerRadius(4)
                .frame(maxHeight: maxImageHeight)
                .fixedSize(horizontal: false, vertical: true)
        }
        
        if let citedPid = postDataWrapper.citedPostID, options.contains(.displayCitedPost) {
            if let citedPost = postDataWrapper.citedPost {
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
            if options.contains(.compactText) {
                textView()
            } else {
                textView()
                    // Apply a transparent background to avoid
                    // offset when presenting context menu
                    .background(Color.clear)
                    .contextMenu(ContextMenu(menuItems: {
                        Button("Copy full text", action: {
                            UIPasteboard.general.string = postDataWrapper.post.text
                        })
                    }))
            }
                    
        }
        
        if hasVote {
            HollowVoteContentView(vote: postDataWrapper.post.vote!, voteHandler: voteHandler, allowVote: !options.contains(.disableVote))
        }

    }
    
    private func textView() -> some View {
        var text: String = postDataWrapper.post.text
        if options.contains(.addTextForImage) && postDataWrapper.post.hollowImage != nil {
            text += "[" + "Image" + "] "
        }
        if postDataWrapper.post.text == "" &&
            postDataWrapper.post.hollowImage != nil &&
            options.contains(.replaceForImageOnly) {
            text = "[" + "Image" + "]"
        }
        return HollowTextView(text: text, compactLineLimit: options.contains(.compactText) ? lineLimit : nil)
    }
}

extension HollowContentView {
    struct DisplayOptions: OptionSet {
        let rawValue: Int
        static let displayVote = DisplayOptions(rawValue: 1 << 1)
        static let displayImage = DisplayOptions(rawValue: 1 << 2)
        static let displayCitedPost = DisplayOptions(rawValue: 1 << 3)
        static let compactText = DisplayOptions(rawValue: 1 << 4)
        static let replaceForImageOnly = DisplayOptions(rawValue: 1 << 5)
        static let addTextForImage = DisplayOptions(rawValue: 1 << 6)
        static let disableVote = DisplayOptions(rawValue: 1 << 7)
    }
}
