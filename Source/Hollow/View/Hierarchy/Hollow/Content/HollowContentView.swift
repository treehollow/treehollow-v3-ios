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
    private var showVote: Bool { hasVote && !hideContent }
    private var hasImage: Bool { postDataWrapper.post.hollowImage != nil }
    
    @Default(.blockedTags) var customBlockedTags
    @Default(.foldPredefinedTags) var foldPredefinedTags
    
    private var hideContent: Bool {
        if options.contains(.revealFoldTags) { return false }
        if let tag = postDataWrapper.post.tag {
            if !foldPredefinedTags {
                return customBlockedTags.contains(tag)
            }
            return foldTags.contains(tag) || customBlockedTags.contains(tag)
        }
        return false
    }
    
    
    private var links: [URL] {
        postDataWrapper.post.text.links().compactMap({ URL(string: $0) })
    }
    
    private var citedPosts: [Int] {
        postDataWrapper.post.text.citationNumbers()
    }
    
    @ScaledMetric(wrappedValue: 4, relativeTo: .body) var body4: CGFloat
    @ScaledMetric(wrappedValue: 6, relativeTo: .body) var body6: CGFloat
    
    @Environment(\.openURL) var openURL
    
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
                            reloadImage: imageReloadHandler,
                            minRatio: (options.contains(.lowerImageAspectRatio) ? 0.2 : 0.7) * (UIDevice.isPad ? 2.3 : 1)
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
                    IntegrationUtilities.conditionallyPresentDetail(store: HollowDetailStore(bindingPostWrapper: .constant(.init(post: citedPost, citedPost: nil))))
                }) {
                    HollowCiteContentView(placeholderPostId: citedPid, postData: postDataWrapper.citedPost)
                }
            } else {
                HollowCiteContentView(placeholderPostId: citedPid, postData: postDataWrapper.citedPost)
            }
        }
        
        if postDataWrapper.post.text != "" && !hideContent {
            textView()
        }
        
        if showVote {
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
        return HollowTextView(postData: postDataWrapper.post, inDetail: !options.contains(.compactText), highlight: postDataWrapper.post.renderHighlight && options.contains(.showHyperlinks), compactLineLimit: options.contains(.compactText) ? lineLimit : nil)
    }
    
    private func tagView(text: String, deleted: Bool) -> some View {
        Text(text)
            .dynamicFont(size: 14, weight: .semibold)
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
        static let showHyperlinks = DisplayOptions(rawValue: 1 << 9)
        static let lowerImageAspectRatio = DisplayOptions(rawValue: 1 << 10)
    }
}
