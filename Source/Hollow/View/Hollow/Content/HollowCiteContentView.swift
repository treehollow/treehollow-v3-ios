//
//  HollowCiteContentView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct HollowCiteContentView: View {
    var placeholderPostId: Int
    var postData: CitedPostData?
    
    var displayedText: String {
        if let postData = self.postData {
            return postData.text == "" ? "[" + NSLocalizedString("TEXTVIEW_PHOTO_PLACEHOLDER_TEXT", comment: "") + "]" : postData.text
        }
        return "Loading" + "..."
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    @ScaledMetric(wrappedValue: 15, relativeTo: .body) var body15: CGFloat
    
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
        .font(.system(size: body15))
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(Color.background)
        
        // Higher opacity for dark mode
        .opacity(colorScheme == .light ? 0.6 : 0.75)
        .foregroundColor(.hollowContentText)
        .cornerRadius(9)
    }
}
