//
//  HollowHeaderView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import AvatarX

// TODO: Actions
struct HollowHeaderView: View {
    @ObservedObject var viewModel: HollowHeader = .init()
    var postData: PostData
    var compact: Bool
    var showContent = false
    private var starred: Bool? { postData.attention }
    
    @Namespace private var headerNamespace
    
    @ScaledMetric(wrappedValue: 37, relativeTo: .body) var body37: CGFloat
    @ScaledMetric(wrappedValue: 16, relativeTo: .body) var body16: CGFloat
    @ScaledMetric(wrappedValue: 13, relativeTo: .body) var body13: CGFloat
    
    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: .top) {
                let tintColor = ViewConstants.avatarTintColors[postData.postId % ViewConstants.avatarTintColors.count]
                AvatarWrapper(
                    colors: [tintColor, .white],
                    resolution: 6,
                    padding: body37 * 0.1,
                    value: postData.postId
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
                        if showContent {
                            // Time label
                            secondaryText(timeLabelText, fontWeight: .medium)
                                .matchedGeometryEffect(id: "time.label", in: headerNamespace)
                        }
                    }
                    if showContent {
                        let postDescription =
                            postData.text != "" ?
                            postData.text.removeLineBreak() : "[" + NSLocalizedString("TEXTVIEW_PHOTO_PLACEHOLDER_TEXT", comment: "") + "]"
                            
                        secondaryText(postDescription, fontWeight: .semibold)
                    } else {
                        // Time label
                        secondaryText(timeLabelText, fontWeight: .semibold)
                            .matchedGeometryEffect(id: "time.label", in: headerNamespace)
                    }
                }
            }

            Spacer()
            
            if !compact {
                // If `postData.attention` is nil, it means that the changed state of attention is submitting
                if let _ = postData.attention {
                    HollowStarButton(attention: postData.attention, likeNumber: postData.likeNumber, starHandler: viewModel.starPost)
                } else {
                    Spinner(color: .hollowCardStarUnselected, desiredWidth: 16)
                }
                
            }
        }
    }
    
    func secondaryText(_ text: String, fontWeight: Font.Weight = .regular) -> some View {
        Text(text)
            .font(.system(size: body13, weight: fontWeight))
            .lineSpacing(2.5)
            .foregroundColor(.hollowCardStarUnselected)
            .lineLimit(1)
    }
}
