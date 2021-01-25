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
        VStack(spacing: 15) {
            HollowHeaderView(postData: $postData)
            if (postData.type == .image || postData.type == .vote) && postData.hollowImage != nil {
                HollowImageView(hollowImage: $postData.hollowImage)
                    .cornerRadius(4)
            }
            
            HollowTextView(text: $postData.text, compact: true)
            
            if postData.type == .vote {
                HollowVoteContentView(vote: Binding($postData.vote)!, viewModel: .init(voteHandler: viewModel.voteHandler))
            }
            
            // Check if comments exist to avoid additional spacing
            if postData.comments.count > 0 {
                CommentView(comments: $postData.comments)
            }
        }
        .padding()
        .background(Color.hollowCardBackground)
        .cornerRadius(8)
        .contentShape(RoundedRectangle(cornerRadius: 8))
        .onTapGesture {
            // Navigate to the detail view
        }
        .contextMenu(ContextMenu(menuItems: {
            HollowHeaderMenu()
        }))
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
                    // FIXME: How to localize this stuff??
                    Text("还有 \(comments.count - maxCommentCount) 条评论")
                        .hollowComment()
                        .foregroundColor(.gray)
                        .padding(.top)
                }
            }
        }
    }

}

struct HollowTimelineCardView_Previews: PreviewProvider {
    static let text = """
    树洞新功能投票
    洞友们好，我们目前正在进行下一代树洞的开发。我们计划在新版树洞中新增用户性别展示功能，现就这一功能征求意见。该功能的具体描述如下：
    每位用户可以设置一次自己的性别，设置后无法更改。性别选项有三个：男，女以及保密。
    所有树洞和评论都会展示发布者的性别。
    可在设置中关闭性别展示功能。关闭后，该终端将不展示任何内容的发布者性别。
    支持新增该功能请回复1，反对新增该功能请回复2，其他观点请直接评论。投票有效时间为24h。支持和反对的洞友也可以留下评论，我们会认真考虑洞友们提出的意见和建议的，谢谢大家
    """
    static let postData: PostData = .init(attention: true, deleted: false, likeNumber: 21, permissions: [], postId: 198431, replyNumber: 12, tag: "", text: text, type: .vote, hollowImage: .init(placeholder: (1760, 1152), image: UIImage(named: "test")), vote: .init(voted: true, votedOption: "不同意", voteData: [
        .init(title: "同意", voteCount: 24),
        .init(title: "不同意", voteCount: 154)
    ]), comments: [
        .init(commentId: 10000, deleted: false, name: "Alice", permissions: [], postId: 10000, tags: [], text: "太抽象了，太批爆了", type: .text, image: nil),
        .init(commentId: 10001, deleted: false, name: "Alice", permissions: [], postId: 10000, tags: [], text: "爷爷大象笑", type: .text, image: nil),
        .init(commentId: 10002, deleted: false, name: "Bob", permissions: [], postId: 10000, tags: [], text: "允", type: .text, image: nil),
        .init(commentId: 10003, deleted: false, name: "Carol", permissions: [], postId: 10000, tags: [], text: "讲道理 这可以当作图灵测试", type: .text, image: nil)
        
    ])
    
    static var previews: some View {
        ScrollView {
            HollowTimelineCardView(postData: .constant(postData), viewModel: .init(voteHandler: {string in print(string)}))
                .padding()
                .background(Color.background)
            HollowTimelineCardView(postData: .constant(postData), viewModel: .init(voteHandler: {string in print(string)}))
                .padding()
                .background(Color.background)
                .colorScheme(.dark)
        }
    }
}

