//
//  HollowTextView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

struct HollowTextView: View {
    var postData: PostData
    var inDetail: Bool
    var highlight: Bool
    
    var compactLineLimit: Int? = nil
    
    @Environment(\.openURL) var openURL
    
    var body: some View {
        if inDetail {
            Menu(content: {
                if postData.text != "" {
                    Button(action: {
                        UIPasteboard.general.string = postData.text
                    }, label: {
                        Label(NSLocalizedString("COMMENT_VIEW_COPY_TEXT_LABEL", comment: ""), systemImage: "doc.on.doc")
                    })
                    Divider()
                }
                if postData.hasURL {
                    let links = Array(postData.text.links().compactMap({ URL(string: $0) }))
                    Divider()
                    ForEach(links, id: \.self) { link in
                        Button(action: {
                            let helper = OpenURLHelper(openURL: openURL)
                            try? helper.tryOpen(link, method: Defaults[.openURLMethod])
                        }) {
                            Label(link.absoluteString, systemImage: "link")
                        }
                    }
                    Divider()
                }
                if postData.hasCitedNumbers {
                    let citedPosts = postData.text.citationNumbers()
                    ForEach(citedPosts, id: \.self) { post in
                        let wrapper = PostDataWrapper.templatePost(for: post)
                        Button(action: {
                            presentView {
                                HollowDetailView(store: .init(bindingPostWrapper: .constant(wrapper)))
                            }
                        }) {
                            Label("#\(post.string)", systemImage: "text.quote")
                        }
                    }
                    Divider()
                }

            }, label: { textView })
        } else {
            textView
        }
    }
    
    var textView: some View {
        Group {
            if highlight {
                Text.highlightLinksAndCitation(postData.text, modifiers: {
                    $0.underline()
                        .foregroundColor(.hollowContentText)
                })
            } else {
                Text(postData.text)
            }
        }
        .modifier(TextModifier(inDetail: inDetail, compactLineLimit: compactLineLimit))
    }
    
    struct TextModifier: ViewModifier {
        var inDetail: Bool
        var compactLineLimit: Int? = nil
        
        func body(content: Content) -> some View {
            content
                .dynamicFont(size: 16)
                .lineSpacing(3)
                .leading()
                .foregroundColor(inDetail ? .primary : .hollowContentText)
                .lineLimit(compactLineLimit)
        }
    }
}
