//
//  HollowCommentContentView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/19.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct HollowCommentContentView: View {
    var commentData: CommentData
    var compact: Bool
    var contentVerticalPadding: CGFloat? = 10
    private let compactLineLimit = 3
    private let nameLabelWidth: CGFloat = 60
    
    @ScaledMetric(wrappedValue: 15, relativeTo: .body) var body15: CGFloat
    @ScaledMetric(wrappedValue: 16, relativeTo: .body) var body16: CGFloat

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
                        .allowsTightening(true)
                        .minimumScaleFactor(0.3)
                        .lineLimit(compact ? 2 : nil)
                        .leading()
                        .frame(width: nameLabelWidth)
                        .fixedSize()
                    VStack(alignment: .leading, spacing: 0) {
                        if commentData.type == .image && !compact {
                            HollowImageView(hollowImage: commentData.image)
                                .cornerRadius(4)
                                .padding(.bottom, 10)
                                .frame(maxHeight: 300)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Group {
                            if commentData.text != "" {
                                Text(commentData.text)
                            } else if commentData.type == .image && compact {
                                (Text("[") + Text(LocalizedStringKey("Photo")) + Text("]"))
                                    .foregroundColor(.uiColor(.secondaryLabel))
                            }
                            // TODO: Has replies indicator
                        }
                        .leading()
                        .lineLimit(compact ? compactLineLimit : nil)
                        .layoutPriority(1)
                    }
                }

                if commentData.type == .image && compact {
                    Image(systemName: "photo")
                        .font(.system(size: body15))
                        .layoutPriority(1)
                }
                
            }
            .font(.system(size: body15))
            .lineSpacing(3)
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
        .font(.system(size: body16))
        // Why do we need to put this here?
        .fixedSize(horizontal: false, vertical: true)
    }
}

#if DEBUG
struct HollowCommentContentView_Previews: PreviewProvider {
    static var previews: some View {
        HollowCommentContentView(commentData: testComments[0], compact: false)
        HollowCommentContentView(commentData: testComments[3], compact: false)
    }
}
#endif
