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
    var text: String
    var inDetail: Bool
    var highlight: Bool
    var links: [String] = []
    var citedNumbers: [Int] = []
    
    var compactLineLimit: Int? = nil
    
    init(postData: PostData, inDetail: Bool, highlight: Bool, links: [String], citedNumbers: [Int], compactLineLimit: Int? = nil) {
        self.text = postData.text
        self.inDetail = inDetail
        self.highlight = highlight
        self.links = links
        self.citedNumbers = citedNumbers
        self.compactLineLimit = compactLineLimit
    }
    
    init(text: String, hasURL: Bool = true, hasCitedNumbers: Bool = true, inDetail: Bool, highlight: Bool, compactLineLimit: Int? = nil) {
        self.text = text
        self.inDetail = inDetail
        self.highlight = highlight
        self.links = text.links()
        self.citedNumbers = text.citationNumbers()
        self.compactLineLimit = compactLineLimit
    }
    
    @Environment(\.openURL) var openURL
    
    var body: some View {
        if inDetail {
            #if targetEnvironment(macCatalyst)
            textView
                .contextMenu { contextMenu }
            #else
            Menu(content: { contextMenu }, label: { textView })
            #endif
        } else {
            textView
        }
    }
    
    var textView: some View {
        Group {
            if highlight {
                Text.highlightLinksAndCitation(text, modifiers: {
                    $0.underline()
                        .foregroundColor(.hollowContentText)
                })
                
            } else {
                Text(text)
                
            }
        }
        
        .modifier(TextModifier(inDetail: inDetail, compactLineLimit: compactLineLimit))
    }
    
    @ViewBuilder var contextMenu: some View {
        if text != "" {
            Button(action: {
                UIPasteboard.general.string = text
            }, label: {
                Label(NSLocalizedString("COMMENT_VIEW_COPY_TEXT_LABEL", comment: ""), systemImage: "doc.on.doc")
            })
            Divider()
        }
        let links = Array(links.compactMap({ URL(string: $0) }))
        if !links.isEmpty {
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
        
        let citedPosts = citedNumbers
        if !citedPosts.isEmpty {
            ForEach(citedPosts, id: \.self) { post in
                let wrapper = PostDataWrapper.templatePost(for: post)
                Button(action: {
                    IntegrationUtilities.conditionallyPresentDetail(store: .init(bindingPostWrapper: .constant(wrapper)))
                }) {
                    Label("#\(post.string)", systemImage: "text.quote")
                }
            }
            Divider()
        }
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
