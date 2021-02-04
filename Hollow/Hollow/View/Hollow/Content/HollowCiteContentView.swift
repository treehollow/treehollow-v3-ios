//
//  HollowCiteContentView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct HollowCiteContentView: View {
    var postData: CitedPostData
    var body: some View {
        VStack(spacing: 7) {
            Text("#\(postData.postId.string)")
                .bold()
                .leading()
            Text(postData.text)
                .lineLimit(2)
        }
        .font(.system(size: 15))
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(Color.background)
        .opacity(0.5)
        .foregroundColor(.hollowContentText)
        .cornerRadius(9)
    }
}

struct HollowCiteContentView_Previews: PreviewProvider {
    static var previews: some View {
        HollowCiteContentView(postData: .init(postId: testPostData.postId, text: testPostData.text))
            .background(Color.hollowCardBackground)
            .colorScheme(.dark)
    }
}
