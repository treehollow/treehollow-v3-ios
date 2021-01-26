//
//  HollowHeaderView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

// TODO: Actions
struct HollowHeaderView: View {
    @ObservedObject var viewModel: HollowHeader
    @Binding var postData: PostData
    var compact: Bool
    private var starred: Bool? { postData.attention }
    
    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: .top) {
                // FIXME: Random avatar
                Image("test")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 37, height: 37)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text("#\(postData.postId.string)")
                        .fontWeight(.medium)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .hollowPostId()
                        .foregroundColor(.hollowContentText)
                    Text("6分钟前")    // Placeholder here
                        .hollowPostTime()
                        .foregroundColor(Color.gray)
                }
            }
            Spacer()
            
            if !compact {
                // If `postData.attention` is nil, it means that the changed state of attention is submitting
                if let _ = postData.attention {
                    HollowStarButton(attention: $postData.attention, likeNumber: $postData.likeNumber, starHandler: viewModel.starHandler)
                } else {
                    Spinner(color: .hollowCardStarUnselected, desiredWidth: 16)
                }
                
                Menu(content: {
                    HollowHeaderMenu()
                }, label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.hollowCardStarUnselected)
                        .padding(5)
                })
            }
        }
    }
}

struct HollowHeaderView_Previews: PreviewProvider {
    static let postData: PostData = .init(attention: true, deleted: false, likeNumber: 21, permissions: [], postId: 198431, replyNumber: 12, tag: "", text: "", type: .vote, hollowImage: .init(placeholder: (1760, 1152), image: UIImage(named: "test")), vote: .init(voted: true, votedOption: "Yes", voteData: [
        .init(title: "Yes", voteCount: 123),
        .init(title: "No", voteCount: 24)
    ]), comments: [
        .init(commentId: 10000, deleted: false, name: "Alice", permissions: [], postId: 10000, tags: [], text: "太抽象了，太批爆了", type: .text, image: nil),
        .init(commentId: 10001, deleted: false, name: "Alice", permissions: [], postId: 10000, tags: [], text: "爷爷大象笑", type: .text, image: nil),
        .init(commentId: 10002, deleted: false, name: "Bob", permissions: [], postId: 10000, tags: [], text: "允", type: .text, image: nil),
        .init(commentId: 10003, deleted: false, name: "Carol", permissions: [], postId: 10000, tags: [], text: "讲道理 这可以当作图灵测试", type: .text, image: nil)
        
    ])
    
    static var previews: some View {
        HollowHeaderView(viewModel: .init(starHandler: {_ in}), postData: .constant(postData), compact: false)
            .background(Color.background)
    }
}
