//
//  HollowHeaderView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct HollowHeaderView: View {
    var postData: PostData
    var compact: Bool
    var showContent = false
    var starAction: (_ star: Bool) -> Void
    var disableAttention: Bool

    var body: some View {
        _HollowHeaderView<EmptyView>(postData: postData, compact: compact, showContent: showContent, starAction: starAction, disableAttention: disableAttention)
    }
}

struct _HollowHeaderView<MenuContent: View>: View {
    var postData: PostData
    var compact: Bool
    var showContent = false
    var starAction: (_ star: Bool) -> Void
    var disableAttention: Bool
    private var starred: Bool? { postData.attention }
    
    var menuContent: (() -> MenuContent)? = nil
    
    @Namespace private var headerNamespace
    
    @ScaledMetric(wrappedValue: 37, relativeTo: .body) var body37: CGFloat
    @ScaledMetric(wrappedValue: 16, relativeTo: .body) var body16: CGFloat
    
    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: .top) {
                let tintColor = ViewConstants.avatarTintColors[postData.colorIndex]
                Avatar(
                    foregroundColor: tintColor,
                    backgroundColor: .white,
                    resolution: 6,
                    padding: body37 * 0.1,
                    hashValue: postData.hash
                )
                // Scale the avatar relative to the font scaling.
                .frame(width: body37, height: body37)
                .clipShape(Circle())
                .overlay(Circle().stroke(lineWidth: 2).foregroundColor(tintColor))
                VStack(alignment: .leading, spacing: 2) {
                    let timeLabelText = HollowDateFormatter(date: postData.timestamp).formattedString(compact: compact)
                    HStack {
                        Text("#\(postData.postId.string)")
                            .fontWeight(.medium)
                            .font(.system(size: body16, weight: .semibold))
                            .foregroundColor(.hollowContentText)
                            .singleLineText()
                        if showContent {
                            // Time label
                            secondaryText(timeLabelText, fontWeight: .medium)
                                .minimumScaleFactor(0.5)
                                .matchedGeometryEffect(id: "time.label", in: headerNamespace)
                        }
                    }
                    if showContent {
                        let postDescription =
                            postData.text != "" ?
                            postData.text :
                            postData.hollowImage != nil ?
                            "[" + NSLocalizedString("TEXTVIEW_PHOTO_PLACEHOLDER_TEXT", comment: "") + "]" : ""
                        
                        secondaryText(postDescription, fontWeight: .semibold)
                    } else {
                        // Time label
                        secondaryText(timeLabelText, fontWeight: .semibold)
                            .minimumScaleFactor(0.5)
                            .matchedGeometryEffect(id: "time.label", in: headerNamespace)
                    }
                }
            }

            Spacer()
            
            if !compact {
                let attention = postData.attention
                Button(action: { starAction(!attention) }) {
                    HStack(spacing: 3) {
                        Text("\(postData.likeNumber)")
                        Image(systemName: attention ? "star.fill" : "star")
                    }
                    .modifier(HollowButtonStyle())
                    .padding(.vertical, 5)
                    .foregroundColor(attention ? .hollowCardStarSelected : .hollowCardStarUnselected)
                }
                .disabled(disableAttention)

                if let menuContent = menuContent {
                    Menu(content: { menuContent() }, label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .frame(width: body16, height: body16)
                            .padding(5)
                            .padding(.vertical, 5)
                            .padding(.leading, 2)
                            .foregroundColor(.hollowCardStarUnselected)
                            .modifier(HollowButtonStyle())
                    })
                }
            }
        }
    }
    
    func secondaryText(_ text: String, fontWeight: Font.Weight = .regular) -> some View {
        Text(text)
            .dynamicFont(size: 13, weight: fontWeight)
            .lineSpacing(2.5)
            .foregroundColor(.hollowCardStarUnselected)
            .lineLimit(1)
    }
}
