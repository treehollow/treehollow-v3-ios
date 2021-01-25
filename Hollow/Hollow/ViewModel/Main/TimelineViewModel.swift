//
//  TimelineViewModel.swift
//  Hollow
//
//  Created by 梁业升 on 2021/1/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

class TimelineViewModel: ObservableObject {
    @Published var posts: [PostData]
    
    init() {
        // FOR DEBUG
        let text = """
        树洞新功能投票
        洞友们好，我们目前正在进行下一代树洞的开发。我们计划在新版树洞中新增用户性别展示功能，现就这一功能征求意见。该功能的具体描述如下：
        每位用户可以设置一次自己的性别，设置后无法更改。性别选项有三个：男，女以及保密。
        所有树洞和评论都会展示发布者的性别。
        可在设置中关闭性别展示功能。关闭后，该终端将不展示任何内容的发布者性别。
        支持新增该功能请回复1，反对新增该功能请回复2，其他观点请直接评论。投票有效时间为24h。支持和反对的洞友也可以留下评论，我们会认真考虑洞友们提出的意见和建议的，谢谢大家
        """
        let postData: PostData = .init(attention: true, deleted: false, likeNumber: 21, permissions: [], postId: 198431, replyNumber: 12, tag: "", text: text, type: .vote, hollowImage: .init(placeholder: (1760, 1152), image: UIImage(named: "test")), vote: .init(voted: true, votedOption: "不同意", voteData: [
            .init(title: "同意", voteCount: 24),
            .init(title: "不同意", voteCount: 154)
        ]), comments: [
            .init(commentId: 10000, deleted: false, name: "Alice", permissions: [], postId: 10000, tags: [], text: "太抽象了，太批爆了", type: .text, image: nil),
            .init(commentId: 10001, deleted: false, name: "Alice", permissions: [], postId: 10000, tags: [], text: "爷爷大象笑", type: .text, image: nil),
            .init(commentId: 10002, deleted: false, name: "Bob", permissions: [], postId: 10000, tags: [], text: "允", type: .text, image: nil),
            .init(commentId: 10003, deleted: false, name: "Carol", permissions: [], postId: 10000, tags: [], text: "讲道理 这可以当作图灵测试", type: .text, image: nil)
            
        ])

        self.posts = Array.init(repeating: postData, count: 10)
    }
    
    func vote(postId: Int, for option: String) {
        
    }
}
