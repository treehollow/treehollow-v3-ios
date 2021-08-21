//
//  HollowTextView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

@available(iOS 15, *)
struct HollowTextView_15: View {
    var attributedString: AttributedString
    var highlight: Bool
    
    init(text: String, highlight: Bool) {
        self.highlight = highlight
        self.attributedString = highlight ? text.attributedForCitationAndLink() : AttributedString(text)
    }
    
    init(attributedString: AttributedString, highlight: Bool) {
        self.highlight = highlight
        self.attributedString = attributedString
    }
    
    var body: some View {
        Text(attributedString)
            .dynamicFont(size: 16)
            .lineSpacing(3)
            .leading()
    }
}

struct HollowTextView_14: View {
    var text: Text
    
    init(text: Text) {
        self.text = text;
    }
    
    var body: some View {
        text
            .dynamicFont(size: 16)
            .lineSpacing(3)
            .leading()
    }
}

struct HollowTextView: View {
    var text: String
    var highlight: Bool
    
    var body: some View {
        if #available(iOS 15, *) {
            HollowTextView_15(text: text, highlight: highlight)
        } else {
            HollowTextView_14(text: Text(text))
        }
    }
}
