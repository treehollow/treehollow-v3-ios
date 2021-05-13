//
//  HollowCiteContentView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI
import Defaults

struct HollowCiteContentView: View {
    var placeholderPostId: Int
    var postData: PostData?
    
    private var foldTags: [String] { Defaults[.hollowConfig]?.foldTags ?? [] }

    @Default(.blockedTags) var customBlockedTags
    @Default(.foldPredefinedTags) var foldPredefinedTags
    
    private var hideContent: Bool {
        if let tag = postData?.tag {
            if !foldPredefinedTags {
                return customBlockedTags.contains(tag)
            }
            return foldTags.contains(tag) || customBlockedTags.contains(tag)
        }
        return false
    }

    
    var displayedText: String {
        if let postData = self.postData {
            if hideContent { return "#" + (postData.tag ?? "") }
            if postData.text != "" { return postData.text.removeLineBreak() }
            if postData.hollowImage != nil { return "[" + NSLocalizedString("TEXTVIEW_PHOTO_PLACEHOLDER_TEXT", comment: "") + "]" }
            return ""
        }
        return NSLocalizedString("CITECONTENTVIEW_LOADING_POST_LABEL", comment: "") + "..."
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            
            Text("#\(placeholderPostId.string)")
                .fontWeight(.semibold)
                .leading()
            
            if let error = postData?.loadingError {
                Label(error, systemImage: "exclamationmark.triangle")
                    .lineLimit(1)
            } else {
                Text(displayedText)
                    .lineLimit(1)
            }
        }
        .dynamicFont(size: 15)
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(Color.background)
        
        // Higher opacity for dark mode
        .opacity(colorScheme == .light ? 0.6 : 0.75)
        .foregroundColor(.hollowContentText)
        .roundedCorner(9)
    }
}
