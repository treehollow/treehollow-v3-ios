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
