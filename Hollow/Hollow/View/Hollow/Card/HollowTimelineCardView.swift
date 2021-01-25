//
//  HollowTimelineCardView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct HollowTimelineCardView: View {
    @Binding var postData: PostData
    @ObservedObject var viewModel: HollowTimelineCardViewModel
    private let verticalSpacing: CGFloat = 10
    var body: some View {
        VStack(spacing: 13) {
            if postData.type == .image {
                HollowImageView(hollowImage: $postData.hollowImage)
            }
            
            HollowTextView(text: $postData.text)
            
            if postData.type == .vote {
                HollowVoteContentView(vote: Binding($postData.vote)!, viewModel: HollowVoteContentViewModel(voteHandler: viewModel.voteHandler))
            }
            
            // Check if comments exist to avoid additional spacing
            if postData.comments.count > 0 {                    CommentView(comments: $postData.comments)
                    .padding(.horizontal, 10)
            }
        }
        .background(Color.uiColor(.systemBackground))
        .cornerRadius(8)
    }
    
    struct CommentView: View {
        @Binding var comments: [CommentData]
        /// Max comments to be displayed in the timeline card.
        private let maxCommentCount = 3
        var body: some View {
            VStack(spacing: 0) {
                // The comment number might change if auto update, so use Identifiable protocol on `CommentData`.
                ForEach(comments.prefix(maxCommentCount)) { comment in
                    HollowCommentContentView(commentData: .constant(comment), compact: true, contentVerticalPadding: 10)
                }
                if comments.count > maxCommentCount {
                    Text("还有 \(comments.count - maxCommentCount) 条评论")
                        .hollowComment()
                        .foregroundColor(.gray)
                        .padding(.vertical, 10)
                }
            }
        }
    }

}

struct HollowTimelineCardView_Previews: PreviewProvider {
    static let text = "带带，XS👴L，2021年害🈶️冥🐷斗士🉑️害彳亍，👼👼宁❤美🍜，美🍜爱宁🐴，84坏94👄，8👀👀宁美👨早⑨8配和我萌种🌹家√线？我👀宁⑨④太⑨站不⑦来，④⭕＋🇩🇪🐶东西，宁美👨，选个戏子当粽子🚮的🍜＋。墙🍅好东西批爆，⑨④🍚📃宁这样🇩🇪傻🐶出去丢种🌹＋脸，举报三连8送🐢vans了"
    
    static var previews: some View {
//        HollowTimelineCardView(postData: .constant(.init(attention: true, deleted: false, likeNumber: 21, permissions: [], postId: 10086, replyNumber: 12, tag: "", text: text, type: .image, hollowImage: .init(placeholder: (1760, 1152), image: UIImage(named: "test")), vote: nil, comments: [
//            .init(commentId: 10000, deleted: false, name: "Alice", permissions: [], postId: 10000, tags: [], text: "太抽象了，太批爆了", type: .text, image: nil),
//            .init(commentId: 10001, deleted: false, name: "Alice", permissions: [], postId: 10000, tags: [], text: "爷爷大象笑", type: .text, image: nil),
//            .init(commentId: 10002, deleted: false, name: "Bob", permissions: [], postId: 10000, tags: [], text: "允", type: .text, image: nil),
//            .init(commentId: 10003, deleted: false, name: "Carol", permissions: [], postId: 10000, tags: [], text: "讲道理 这可以当作图灵测试", type: .text, image: nil)
//
//        ])), viewModel: .init(voteHandler: {string in print(string)}))
        HollowTimelineCardView(postData: .constant(.init(attention: true, deleted: false, likeNumber: 21, permissions: [], postId: 10086, replyNumber: 12, tag: "", text: text, type: .vote, hollowImage: .init(placeholder: (1760, 1152), image: UIImage(named: "test")), vote: .init(voted: true, votedOption: "yes", voteData: [
            .init(title: "yes", voteCount: 102),
            .init(title: "no", voteCount: 21)
        ]), comments: [
            .init(commentId: 10000, deleted: false, name: "Alice", permissions: [], postId: 10000, tags: [], text: "太抽象了，太批爆了", type: .text, image: nil),
            .init(commentId: 10001, deleted: false, name: "Alice", permissions: [], postId: 10000, tags: [], text: "爷爷大象笑", type: .text, image: nil),
            .init(commentId: 10002, deleted: false, name: "Bob", permissions: [], postId: 10000, tags: [], text: "允", type: .text, image: nil),
            .init(commentId: 10003, deleted: false, name: "Carol", permissions: [], postId: 10000, tags: [], text: "讲道理 这可以当作图灵测试", type: .text, image: nil)
            
        ])), viewModel: .init(voteHandler: {string in print(string)}))

    }
}

