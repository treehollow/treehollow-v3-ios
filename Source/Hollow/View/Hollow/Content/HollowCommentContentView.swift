//
//  HollowCommentContentView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/19.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Defaults

struct HollowCommentContentView: View {
    @Binding var commentData: CommentData
    var compact: Bool
    var contentVerticalPadding: CGFloat? = 10
    var hideLabel: Bool = false
    var imageReloadHandler: ((HollowImage) -> Void)? = nil
    private let compactLineLimit = 3
    private var nameLabelWidth: CGFloat {
        return compact ? body60 : body45
    }
    
    @State private var screenSize = UIScreen.main.bounds.size
    
    @ScaledMetric(wrappedValue: 60, relativeTo: .body) var body60: CGFloat
    @ScaledMetric(wrappedValue: 45, relativeTo: .body) var body45: CGFloat
    @ScaledMetric(wrappedValue: 14, relativeTo: .body) var body14: CGFloat
    @ScaledMetric(wrappedValue: 12, relativeTo: .body) var body12: CGFloat
    @ScaledMetric(wrappedValue: 15, relativeTo: .body) var body15: CGFloat
    @ScaledMetric(wrappedValue: 16, relativeTo: .body) var body16: CGFloat
    @ScaledMetric(wrappedValue: 5, relativeTo: .body) var body5: CGFloat
    @ScaledMetric(wrappedValue: 4, relativeTo: .body) var body4: CGFloat
    @ScaledMetric(wrappedValue: 2, relativeTo: .body) var body2: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            if let padding = contentVerticalPadding {
                Spacer(minLength: padding)
                    .fixedSize()
            }
            HStack {
                HStack(alignment: .top) {
                    Group { if hideLabel {
                        Spacer(minLength: nameLabelWidth)
                    } else {
                        if compact {
                            Text(commentData.name)
                                .bold()
                                .allowsTightening(true)
                                .minimumScaleFactor(0.3)
                                .lineLimit(compact ? 2 : nil)
                                .leading()
                                .frame(width: nameLabelWidth)
                                .fixedSize()
                        } else {
                            avatarView
                        }
                    }}
                    VStack(alignment: .leading, spacing: compact ? 0 : body5) {
                        if !compact {
                            HStack {
                                Text(commentData.name)
                                    .bold()
                                    .lineLimit(1)
                                
                                if let tag = commentData.tag {
                                    Text(tag)
                                        .font(.system(size: body12, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.vertical, body2)
                                        .padding(.horizontal, body4)
                                        .background(Color.hollowContentVoteGradient1)
                                        .cornerRadius(body5)
                                }
                                Spacer()
                                Text(HollowDateFormatter(date: commentData.date).formattedString())
                                    .font(.system(size: body14, weight: .medium))
                                    .foregroundColor(.hollowCardStarUnselected)
                                    .lineLimit(1)
                            }
                        }
                        
                        if commentData.type == .image && !compact {
                            HollowImageView(
                                hollowImage: commentData.image,
                                description: commentData.text,
                                reloadImage: imageReloadHandler
                            )
                            .cornerRadius(4)
                            .padding(.bottom, 10)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                        Group {
                            if commentData.text != "" {
                                Text(commentData.text)
                            } else if commentData.type == .image && compact {
                                (Text("[") + Text("TEXTVIEW_PHOTO_PLACEHOLDER_TEXT") + Text("]"))
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
        .fixedSize(horizontal: false, vertical: true)
    }
    
    
    @ViewBuilder var avatarView: some View {
        let avatarWidth = nameLabelWidth * 0.7
        let hashRoot = commentData.name + commentData.postId.string
        let index = abs(hashRoot.hash) % ViewConstants.avatarTintColors.count
        // FIXME: Put into one place
        let postTintColor = ViewConstants.avatarTintColors[commentData.postId % ViewConstants.avatarTintColors.count]
        let color = commentData.isDz ? postTintColor : ViewConstants.avatarTintColors[index]
        Group {
            if commentData.isDz {
                AvatarWrapper(colors: [color, .white], resolution: 6, padding: avatarWidth * 0.1, value: commentData.postId)
            } else {
                AvatarWrapper(colors: [color, .white], resolution: 4, padding: avatarWidth * 0.1, value: hashRoot)
            }
        }
        .frame(width: avatarWidth)
        .clipShape(Circle())
        .overlay(Circle().stroke(lineWidth: 2).foregroundColor(color))
        .leading()
        .frame(width: nameLabelWidth)
        .fixedSize()
        
    }
    
}
