//
//  HollowContentView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

struct HollowContentView: View {
    var detailStore: HollowDetailStore?
    @State private var newDetailStore: HollowDetailStore?
    var postDataWrapper: PostDataWrapper
    var options: DisplayOptions
    var voteHandler: (String) -> Void
    // We get this value from the parent.
    var maxImageHeight: CGFloat? = nil
    var lineLimit: Int = 12
    
    var imageReloadHandler: ((HollowImage) -> Void)? = nil
    
    private let foldTags = Defaults[.hollowConfig]?.foldTags ?? []
    
    private var hasVote: Bool { postDataWrapper.post.vote != nil }
    private var hasImage: Bool { postDataWrapper.post.hollowImage != nil }
    private var hideContent: Bool {
        if options.contains(.revealFoldTags) { return false }
        if let tag = postDataWrapper.post.tag {
            return foldTags.contains(tag)
        }
        return false
    }
    
    @ScaledMetric(wrappedValue: 14, relativeTo: .body) var body14: CGFloat
    @ScaledMetric(wrappedValue: 4, relativeTo: .body) var body4: CGFloat
    @ScaledMetric(wrappedValue: 6, relativeTo: .body) var body6: CGFloat
    
    var body: some View {
        if postDataWrapper.post.tag != nil || postDataWrapper.post.deleted {
            HStack(spacing: body6) {
                if postDataWrapper.post.deleted {
                    tagView(text: NSLocalizedString("HOLLOW_CONTENT_DELETED_TAG", comment: ""), deleted: true)
                }
                if let tag = postDataWrapper.post.tag {
                    tagView(text: tag, deleted: false)
                }
                Spacer()
            }
        }
        
        if hasImage && options.contains(.displayImage) && !hideContent {
            HollowImageView(hollowImage: postDataWrapper.post.hollowImage,
                            description: postDataWrapper.post.text,
                            reloadImage: imageReloadHandler
            )
            .roundedCorner(4)
            .frame(maxHeight: maxImageHeight)
            .fixedSize(horizontal: false, vertical: true)
        }
        
        if let citedPid = postDataWrapper.citedPostID,
           options.contains(.displayCitedPost),
           !hideContent {
            if let citedPost = postDataWrapper.citedPost,
               citedPost.loadingError == nil {
                Button(action: {
                    presentView {
                        HollowDetailView(store: HollowDetailStore(bindingPostWrapper: .constant(.init(post: citedPost, citedPost: nil))))
                    }
                }) {
                    HollowCiteContentView(placeholderPostId: citedPid, postData: postDataWrapper.citedPost)
                }
            } else {
                HollowCiteContentView(placeholderPostId: citedPid, postData: postDataWrapper.citedPost)
            }
        }
        
        // Enable the context menu for the text if it is in detail view.
        if postDataWrapper.post.text != "" && !hideContent {
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
        
        if hasVote && !hideContent {
            HollowVoteContentView(vote: postDataWrapper.post.vote!, voteHandler: voteHandler, allowVote: !options.contains(.disableVote))
        }

    }
    
    private func textView() -> some View {
        var text: String = postDataWrapper.post.text
        if options.contains(.addTextForImage) && postDataWrapper.post.hollowImage != nil {
            text += "[" + NSLocalizedString("TEXTVIEW_PHOTO_PLACEHOLDER_TEXT", comment: "") + "] "
        }
        if postDataWrapper.post.text == "" &&
            postDataWrapper.post.hollowImage != nil &&
            options.contains(.replaceForImageOnly) {
            text = "[" + NSLocalizedString("TEXTVIEW_PHOTO_PLACEHOLDER_TEXT", comment: "") + "]"
        }
        return HollowTextView(text: text, compactLineLimit: options.contains(.compactText) ? lineLimit : nil)
    }
    
    private func tagView(text: String, deleted: Bool) -> some View {
        Text(text)
            .font(.system(size: body14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, body6)
            .padding(.vertical, body4)
            .background(deleted ? Color.red : Color.hollowContentVoteGradient1)
            .roundedCorner(body6)
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
        static let revealFoldTags = DisplayOptions(rawValue: 1 << 8)
    }
}
