//
//  HollowContentView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct HollowContentView: View {
    @ObservedObject var viewModel: HollowContentViewModel
    @Binding var postData: PostData
    var compact: Bool
    // TODO: cite content
    var body: some View {
        VStack {
            if postData.type == .image {
                HollowImageView(hollowImage: $postData.hollowImage)
            }
            Text(postData.text)
//                .font(.plain)
                .leading()
                .padding(.vertical, 5)
                .contentShape(RoundedRectangle(cornerRadius: 10))
                .contextMenu(ContextMenu(menuItems: {
                    // TODO: Add actions for text
                    /*@START_MENU_TOKEN@*/Text("Menu Item 1")/*@END_MENU_TOKEN@*/
                    /*@START_MENU_TOKEN@*/Text("Menu Item 2")/*@END_MENU_TOKEN@*/
                    /*@START_MENU_TOKEN@*/Text("Menu Item 3")/*@END_MENU_TOKEN@*/
                }))
            if postData.type == .vote {
                HollowVoteContentView(vote: Binding($postData.vote)!, viewModel: HollowVoteContentViewModel(voteHandler: viewModel.voteHandler))
            }
            // The comment number might change if auto update, so use identifiable protocol.
            if postData.comments.count > 0 {
                Divider()
                CommentView(comments: $postData.comments, compact: compact)
            }
        }
    }
    
    struct CommentView: View {
        @Binding var comments: [CommentData]
        var compact: Bool
        var body: some View {
            VStack {
                ForEach(comments) { commentData in
                    HollowCommentContentView(commentData: .constant(commentData), compact: compact)
                }
            }
        }
    }
}

#if DEBUG
struct HollowContentView_Previews: PreviewProvider {
    static let text = "带带，XS👴L，2021年害🈶️冥🐷斗士🉑️害彳亍，👼👼宁❤美🍜，美🍜爱宁🐴，84坏94👄，8👀👀宁美👨早⑨8配和我萌种🌹家√线？我👀宁⑨④太⑨站不⑦来，④⭕＋🇩🇪🐶东西，宁美👨，选个戏子当粽子🚮的🍜＋。墙🍅好东西批爆，⑨④🍚📃宁这样🇩🇪傻🐶出去丢种🌹＋脸，举报三连8送🐢vans了"
    static var previews: some View {
        HollowContentView(viewModel: .init(voteHandler: {_ in}), postData: .constant(.init(attention: true, deleted: false, likeNumber: 21, permissions: [], postId: 10086, replyNumber: 12, tag: "", text: text, type: .image, hollowImage: .init(placeholder: (1760, 1152), image: UIImage(named: "test")), vote: nil, comments: [
            .init(commentId: 10000, deleted: false, name: "Alice", permissions: [], postId: 10000, tags: [], text: "太抽象了，太批爆了", type: .text, image: nil),
            .init(commentId: 10001, deleted: false, name: "Alice", permissions: [], postId: 10000, tags: [], text: "爷爷大象笑", type: .text, image: nil),
            .init(commentId: 10002, deleted: false, name: "Bob", permissions: [], postId: 10000, tags: [], text: "允", type: .text, image: nil),
            .init(commentId: 10003, deleted: false, name: "Carol", permissions: [], postId: 10000, tags: [], text: "讲道理 这可以当作图灵测试", type: .text, image: nil)

        ])), compact: false)
//        HollowContentView(viewModel: .init(), postData: .constant(.init(attention: true, deleted: false, likeNumber: 21, permissions: [], postId: 10086, replyNumber: 12, tag: "", text: "你是否赞成？", type: .vote, hollowImage: .init(placeholder: (1760, 1152), image: nil), vote: .init(voted: false, votedOption: "", voteData: [
//            .init(title: "赞成", voteCount: -1),
//            .init(title: "反对", voteCount: -1)
//        ]), comments: [
//            .init(commentId: 10000, deleted: false, name: "Alice", permissions: [], postId: 10000, tags: [], text: "林老师的课真的是非常棒的，人也很好，回复学生的问题很尽心尽责", type: .text, image: nil),
//            .init(commentId: 10001, deleted: false, name: "Bob", permissions: [], postId: 10000, tags: [], text: "林老师的课真的是非常棒的，人也很好，回复学生的问题很尽心尽责", type: .text, image: nil)
//        ])), compact: false)
        
    }
}
#endif
