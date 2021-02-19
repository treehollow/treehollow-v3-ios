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
                    HStack {
                        Text("#\(postData.postId.string)")
                            .fontWeight(.medium)
                            .font(.system(size: body16, weight: .semibold))
                            .foregroundColor(.hollowContentText)
                        if showContent {
                            // Time label
                            secondaryText("6 min", fontWeight: .medium)
                                .matchedGeometryEffect(id: "time.label", in: headerNamespace)
                        }
                    }
                    if showContent {
                        secondaryText(postData.text.removeLineBreak())
                    } else {
                        // Time label
                        secondaryText("6 min", fontWeight: .medium)
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
                
                // FIXME: Cannot present full screen cover after presenting this menu
                
//                Menu(content: {
//                    HollowHeaderMenu()
//                }, label: {
//                    Image(systemName: "ellipsis")
//                        .foregroundColor(.hollowCardStarUnselected)
//                        .padding(5)
//                })
            }
        }
    }
    
    func secondaryText(_ text: String, fontWeight: Font.Weight = .regular) -> some View {
        Text(text)
            .font(.system(size: body13, weight: fontWeight))
            .lineSpacing(2.5)
            .foregroundColor(Color.gray)
            .lineLimit(1)
    }
}

#if DEBUG
struct HollowHeaderView_Previews: PreviewProvider {
    static let postData: PostData = .init(attention: true, deleted: false, likeNumber: 21, permissions: [], postId: 198431, replyNumber: 12, tag: "", text: "asdasdsdsdadsdasdsdasdasdasdasdadsdasdasdsadds", hollowImage: .init(placeholder: (1760, 1152), image: UIImage(named: "test"), imageURL: ""), vote: .init(votedOption: "Yes", voteData: [
        .init(title: "Yes", voteCount: 123),
        .init(title: "No", voteCount: 24)
    ]), comments: [
        .init(commentId: 10000, deleted: false, name: "Alice", permissions: [], postId: 10000, tags: [], text: "太抽象了，太批爆了",  image: nil),
        .init(commentId: 10001, deleted: false, name: "Alice", permissions: [], postId: 10000, tags: [], text: "爷爷大象笑",  image: nil),
        .init(commentId: 10002, deleted: false, name: "Bob", permissions: [], postId: 10000, tags: [], text: "允", image: nil),
        .init(commentId: 10003, deleted: false, name: "Carol", permissions: [], postId: 10000, tags: [], text: "讲道理 这可以当作图灵测试",  image: nil)
        
    ])
    
    static var previews: some View {
        HollowHeaderView(postData: postData, compact: false)
            .background(Color.background)
    }
}
#endif
