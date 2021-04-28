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
    var postColorIndex: Int
    var postHash: Int
    var imageReloadHandler: ((HollowImage) -> Void)? = nil
    private let compactLineLimit = 3
    private var nameLabelWidth: CGFloat {
        return compact ? body60 : body45
    }
    
    static let avatarWidth: CGFloat = 45
    static let avatarProportion: CGFloat = 0.7
    
    @ScaledMetric(wrappedValue: 60, relativeTo: .body) var body60: CGFloat
    @ScaledMetric(wrappedValue: avatarWidth, relativeTo: .body) var body45: CGFloat
    @ScaledMetric(wrappedValue: 5, relativeTo: .body) var body5: CGFloat
    @ScaledMetric(wrappedValue: 4, relativeTo: .body) var body4: CGFloat
    @ScaledMetric(wrappedValue: 2, relativeTo: .body) var body2: CGFloat
    
    @Environment(\.colorScheme) var colorScheme
    
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
                            let nameTextView: Text = commentData.isDz ?
                                Text(commentData.name + " ") + Text(Image(systemName: "person.fill")) :
                                Text(commentData.name)
                            HStack {
                                nameTextView
                                    .bold()
                                    .lineLimit(1)
                                
                                if commentData.tag != nil || commentData.deleted {
                                    if commentData.deleted {
                                        tagView(text: NSLocalizedString("HOLLOW_CONTENT_DELETED_TAG", comment: ""), removed: true)
                                    }

                                    if let tag = commentData.tag {
                                        tagView(text: tag, removed: false)
                                    }
                                }
                                Spacer()
                                
                                Text.dateText(commentData.date)
                                    .dynamicFont(size: 14, weight: .medium)
                                    .foregroundColor(.hollowCardStarUnselected)
                                    .lineLimit(1)
                            }
                        }
                        
                        if commentData.image != nil && !compact {
                            HollowImageView(
                                hollowImage: commentData.image,
                                description: commentData.text,
                                reloadImage: imageReloadHandler,
                                minRatio: UIDevice.isPad ? 1.3 : 0.7
                            )
                            .roundedCorner(4)
                            .padding(.top, UIDevice.isMac ? 10 : 0)
                            .padding(.bottom, UIDevice.isMac ? 13 : 10)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                        Group {
                            let replyText = (commentData.replyTo != -1 ?
                                                Text(Image(systemName: "arrow.turn.up.right")) + Text(" ") :
                                                Text("")
                            )
                            .foregroundColor(Color.hollowCardStarUnselected.opacity(colorScheme == .light ? 0.3 : 0.8))

                            if commentData.text != "" {
                                
                                if compact || !commentData.renderHighlight {
                                    replyText + Text(commentData.text)
                                } else {
                                    replyText + Text.highlightLinksAndCitation(commentData.text, modifiers: {
                                        $0.underline()
                                            .foregroundColor(.hollowContentText)
                                    })
                                }
                            } else if commentData.image != nil && compact {
                                (replyText + Text("[") + Text("TEXTVIEW_PHOTO_PLACEHOLDER_TEXT") + Text("]"))
                                    .foregroundColor(.uiColor(.secondaryLabel))
                            }
                        }
                        .leading()
                        .lineLimit(compact ? compactLineLimit : nil)
                        .layoutPriority(1)
                    }
                }
                
                if commentData.image != nil && compact {
                    Image(systemName: "photo")
                        .dynamicFont(size: 15)
                        .layoutPriority(1)
                }
                
            }
            .dynamicFont(size: 15)
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
        .dynamicFont(size: 16)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    
    @ViewBuilder var avatarView: some View {
        let avatarWidth = nameLabelWidth * HollowCommentContentView.avatarProportion
        let postTintColor = ViewConstants.avatarTintColors[postColorIndex]
        let commentTintColor = ViewConstants.avatarTintColors[commentData.colorIndex]
        let color = commentData.isDz ? postTintColor : commentTintColor
        let hash = commentData.isDz ? postHash : commentData.hash
        let resolution = commentData.isDz ? 6 : 4
        Avatar(
            foregroundColor: color,
            backgroundColor: .white,
            resolution: resolution,
            padding: avatarWidth * 0.1,
            hashValue: hash,
            name: commentData.abbreviation
        )
        .frame(width: avatarWidth)
        .clipShape(Circle())
        .overlay(Circle().stroke(lineWidth: 2).foregroundColor(color))
        .leading()
        .frame(width: nameLabelWidth)
        .fixedSize()
        
    }
    
    func tagView(text: String, removed: Bool) -> some View {
        Text(text)
            .dynamicFont(size: 12, weight: .semibold)
            .foregroundColor(.white)
            .padding(.vertical, body2)
            .padding(.horizontal, body4)
            .background(removed ? Color.red : Color.hollowContentVoteGradient1)
            .roundedCorner(body5)
    }
    
}