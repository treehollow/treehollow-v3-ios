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
    
    @ScaledMetric(wrappedValue: 14, relativeTo: .body) var body14: CGFloat
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
                        Button(action: {
                            UIPasteboard.general.string = postDataWrapper.post.text
                        }) {
                            Label("COMMENT_VIEW_COPY_TEXT_LABEL", systemImage: "plus.square.on.square")
                        }
                    }))
            }
                    
        }
        
        if options.contains(.showHyperlinks) &&
            !hideContent {
            let links = self.links
            let citations = self.citedPosts
            if !links.isEmpty || !citations.isEmpty {
                HStack {
                    let links = postDataWrapper.post.text.links()
                    if links.count > 0 {
                        Menu(content: {
                            ForEach(links, id: \.self) { link in
                                Button(link, action: {
                                    guard let url = URL(string: link) else { return }
                                    let helper = OpenURLHelper(openURL: openURL)
                                    try? helper.tryOpen(url)
                                })
                            }
                        } , label: {
                            linkMenuLabel(text: NSLocalizedString("HOLLOW_CONTENT_LINKS_MENU_LABEL", comment: ""), systemImageName: "link")
                        })
                    }
                    if citations.count > 1 {
                        Menu(content: {
                            ForEach(citations, id: \.self) { citation in
                                Button("#\(citation.string)", action: {
                                    let wrapper = PostDataWrapper.templatePost(for: citation)
                                    presentView {
                                        HollowDetailView(store: HollowDetailStore(bindingPostWrapper: .constant(wrapper)))
                                    }
                                })
                            }
                        } , label: {
                            linkMenuLabel(text: NSLocalizedString("HOLLOW_CONTENT_QUOTE_MENU_LABEL", comment: ""), systemImageName: "text.quote")
                        })
                    }
                    Spacer()
                }
                .padding(.top, 1)
                .padding(.bottom, showVote ? 10 : 0)
            }
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
        return HollowTextView(text: text, inDetail: !options.contains(.compactText), highlight: postDataWrapper.post.renderHighlight && options.contains(.showHyperlinks), compactLineLimit: options.contains(.compactText) ? lineLimit : nil)
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
    
    private func linkMenuLabel(text: String, systemImageName: String) -> some View {
        // Keep the same with tagView
        Label(text, systemImage: systemImageName)
            .font(.system(size: body14, weight: .semibold))
            .padding(.horizontal, body6)
            .padding(.vertical, body4)
            .background(Color.background)
            .roundedCorner(body6)
            .accentColor(.hollowContentText)
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
    }
}
