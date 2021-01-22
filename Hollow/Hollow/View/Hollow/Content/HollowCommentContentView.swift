//
//  HollowCommentContentView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/19.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct HollowCommentContentView: View {
    @Binding var commentData: CommentData
    var compact: Bool
    private let compactLineLimit = 3
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Text(commentData.name)
                    .bold()
                    .allowsTightening(true)
                    .lineLimit(compactLineLimit)
                    .leading()
                    .frame(width: 60)
                    .fixedSize()
                    .fixedSizedTop()
                VStack {
                    if commentData.type == .image && !compact {
                        HollowImageView(hollowImage: $commentData.image)
                    }
                    Text(commentData.text)
                        .leading()
                        .lineLimit(compact ? compactLineLimit : nil)
                }
            }
            HStack {
                Spacer(minLength: 60)
                VStack {
                    Divider()
                }
            }
        }
        .font(.plain)
    }
}

struct HollowCommentContentView_Previews: PreviewProvider {
    static var previews: some View {
        HollowCommentContentView(commentData: .constant(.init(commentId: 10000, deleted: false, name: "Zombie Alice Alice Alice", permissions: [], postId: 10000, tags: [], text: "林老师的课真的是非常棒的，人也很好，回复学生的问题很尽心尽责", type: .text, image: nil)), compact: true)
    }
}
