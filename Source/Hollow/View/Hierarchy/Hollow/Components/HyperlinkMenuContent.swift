//
//  HyperlinkMenuContent.swift
//  HyperlinkMenuContent
//
//  Created by liang2kl on 2021/8/21.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

struct HyperlinkMenuContent: View {
    let links: [String]
    let citations: [Int]
    
    @Environment(\.openURL) var openURL

    var body: some View {
        
        ForEach(links, id: \.self) { link in
            Button(link, action: {
                guard let url = URL(string: link) else { return }
                try? OpenURLHelper(openURL: openURL).tryOpen(url, method: Defaults[.openURLMethod])
            })
        }
        
        if !links.isEmpty && !citations.isEmpty {
            Divider()
        }

        ForEach(citations, id: \.self) { citation in
            Button("#\(citation.string)", action: {
                let wrapper = PostDataWrapper.templatePost(for: citation)
                IntegrationUtilities.presentDetailView(store: .init(bindingPostWrapper: .constant(wrapper)))
            })
        }
    }

}
