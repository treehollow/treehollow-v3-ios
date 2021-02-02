//
//  HollowCommentContentView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/19.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import MarkdownUI

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
            HStack {
                HStack(alignment: .top) {
                    Text(commentData.name)
                        .bold()
                        .hollowComment()
                        .minimumScaleFactor(0.75)
                        .allowsTightening(true)
                        .lineLimit(compact ? compactLineLimit : nil)
                        .leading()
                        .frame(width: nameLabelWidth)
                        .fixedSize()
                    VStack(alignment: .leading, spacing: 0) {
                        if commentData.type == .image && !compact {
                            HollowImageView(hollowImage: $commentData.image)
                                .cornerRadius(4)
                                .padding(.bottom, 10)
                                .frame(maxHeight: 300)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Group {
                            if commentData.text != "" {
                                Markdown(Document(stringLiteral: commentData.text))
                                    .markdownStyle(.init(font: .system(size: 16), foregroundColor: .init(compact ? .hollowContentText : .primary)))
                            } else if commentData.type == .image && compact {
                                (Text("[") + Text(LocalizedStringKey("Photo")) + Text("]"))
                                    .hollowContent()
                                    .foregroundColor(.uiColor(.secondaryLabel))
                            }
                        }
                        .leading()
                        .lineLimit(compact ? compactLineLimit : nil)
                        .layoutPriority(1)
                    }
                }
                if commentData.type == .image && compact {
                    Image(systemName: "photo")
                        .font(.system(size: 15))
                        .layoutPriority(1)
                }
                
            }
            .foregroundColor(compact ? .hollowContentText : .primary)
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
        // Why do we need to put this here?
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct HollowCommentContentView_Previews: PreviewProvider {
    static var previews: some View {
        HollowCommentContentView(commentData: .constant(testComments[0]), compact: false)
        HollowDetailView(postData: .constant(testPostData), presentedIndex: .constant(-1))
        HollowCommentContentView(commentData: .constant(testComments[3]), compact: false)
    }
}
