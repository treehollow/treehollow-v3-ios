//
//  HollowCiteContentView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct HollowCiteContentView: View {
    var postData: CitedPostData
    
    @Environment(\.colorScheme) var colorScheme
    
    @ScaledMetric(wrappedValue: 15, relativeTo: .body) var body15: CGFloat
    
    var body: some View {
        VStack(spacing: 7) {
            Text("#\(postData.postId.string)")
                .fontWeight(.semibold)
                .leading()
            Text(postData.text.removeLineBreak())
                .lineLimit(2)
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

#if DEBUG
struct HollowCiteContentView_Previews: PreviewProvider {
    static var previews: some View {
        HollowCiteContentView(postData: .init(postId: testPostData.postId, text: testPostData.text))
            .background(Color.hollowCardBackground)
            .colorScheme(.dark)
    }
}
#endif
