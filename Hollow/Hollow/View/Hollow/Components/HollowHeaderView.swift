//
//  HollowHeaderView.swift
//  Hollow
//
//  Created by 梁业升 on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

// TODO: Actions
struct HollowHeaderView: View {
    @Binding var postData: PostData
    // FIXME: Remove this line and implement the logic in the view model!
    @State var starred = false
    
    var body: some View {
        HStack(alignment: .top) {
            Image("test")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 37, height: 37)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("#\(postData.postId.string)")
                    .hollowPostId()
                    .foregroundColor(.hollowContentText)
                Text("6分钟前")    // Placeholder here
                    .hollowPostTime()
                    .foregroundColor(Color.gray)
            }
            Spacer()
            HStack(spacing: nil) {
                Group {
                    Button(action: {
                        withAnimation {
                            // TODO: Tapic feedback
                            starred.toggle()
                        }
                    }) {
                        HStack(spacing: 3) {
                            Text("\(postData.likeNumber)")
                            Image(systemName: starred ? "star.fill" : "star")
                        }
                        .font(.system(size: 16, weight: .medium))
                    }
                    .padding(5)
                }
                .foregroundColor(starred ? .hollowCardStarSelected : .hollowCardStarUnselected)
                Menu(content: {
                    HollowHeaderMenu()
                }
                , label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.hollowCardStarUnselected)
                        .padding(5)
                }
                )
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
        HollowHeaderView(postData: .constant(postData))
    }
}
