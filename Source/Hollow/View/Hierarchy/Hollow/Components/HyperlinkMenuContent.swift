//
//  HyperlinkMenuContent.swift
//  HyperlinkMenuContent
//
//  Created by liang2kl on 2021/8/21.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct HyperlinkMenuContent: View {
    let links: [String]
    let citations: [Int]
    var genericLabel = true
    
    @Environment(\.openURL) var openURL
    
    @ScaledMetric(wrappedValue: 4, relativeTo: .body) var body4: CGFloat
    @ScaledMetric(wrappedValue: 6, relativeTo: .body) var body6: CGFloat
    

    var body: some View {
        
        if links.count > 0 {
            Menu(content: {
                ForEach(links, id: \.self) { link in
                    Button(link, action: {
                        guard let url = URL(string: link) else { return }
                        openURL(url)
                    })
                }
            } , label: {
                linkMenuLabel(text: NSLocalizedString("HOLLOW_CONTENT_LINKS_MENU_LABEL", comment: ""), systemImageName: "link")
            })
        }
        
        if citations.count > 0 {
            Menu(content: {
                ForEach(citations, id: \.self) { citation in
                    Button("#\(citation.string)", action: {
                        let wrapper = PostDataWrapper.templatePost(for: citation)
                        IntegrationUtilities.presentDetailView(store: .init(bindingPostWrapper: .constant(wrapper)))
                    })
                }
            } , label: {
                linkMenuLabel(text: NSLocalizedString("HOLLOW_CONTENT_QUOTE_MENU_LABEL", comment: ""), systemImageName: "text.quote")
            })
        }
    }
    
    @ViewBuilder private func linkMenuLabel(text: String, systemImageName: String) -> some View {
        if genericLabel {
            Label(text, systemImage: systemImageName)
        } else {
            Text("\(text)  \(Image(systemName: systemImageName))")
                .dynamicFont(size: 14, weight: .semibold)
                .padding(.horizontal, body6 + 3)
                .padding(.vertical, body4)
                .background(Color.background)
                .roundedCorner(body6)
                .accentColor(.hollowContentText)
        }
    }

}
