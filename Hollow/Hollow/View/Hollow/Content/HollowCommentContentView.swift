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
    var contentVerticalPadding: CGFloat? = 10
    private let compactLineLimit = 3
    private let nameLabelWidth: CGFloat = 60
    var body: some View {
        VStack(spacing: 0) {
            if let padding = contentVerticalPadding {
                Spacer(minLength: padding)
                    .fixedSize()
            }
            HStack(alignment: .top) {
                Text(commentData.name)
                    .bold()
                    .hollowComment()
                    .allowsTightening(true)
                    .lineLimit(compactLineLimit)
                    .leading()
                    .frame(width: nameLabelWidth)
                    .fixedSize()
                VStack(spacing: 0) {
                    if commentData.type == .image && !compact {
                        HollowImageView(hollowImage: $commentData.image)
                    }
                    Text(commentData.text)
                        .hollowComment()
                        .leading()
                        .lineLimit(compact ? compactLineLimit : nil)
                }
            }
            .foregroundColor(.hollowContentText)
            if let padding = contentVerticalPadding {
                Spacer(minLength: padding)
                    .fixedSize()
            }
            HStack {
                Spacer(minLength: nameLabelWidth)
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
        HollowCommentContentView(commentData: .constant(.init(commentId: 10000, deleted: false, name: "Alice", permissions: [], postId: 10000, tags: [], text: "林老师的课真的是非常棒的，人也很好，回复学生的问题很尽心尽责", type: .text, image: nil)), compact: true)
    }
}
