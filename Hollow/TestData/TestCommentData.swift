//
//  TestCommentData.swift
//  Hollow
//
//  Created by 梁业升 on 2021/1/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

#if DEBUG
import SwiftUI

let testComments: [CommentData] = [
    .init(commentId: 10000, deleted: false, name: "Alice", permissions: [], postId: 10000, tags: [], text: """
        提醒一下洞里想走校级交换的ddmm，到时候一定要主动跟外办跟进，不要对世一大外办的办事过于信任。
        我们21春一波人的校级交换，外办基本就干了两件事:学期初扔给你一个申请网址，以及等到所有申请流程都自己走完，只差拎包走人的时候告诉你去不了。
        反观
        """, type: .image, image: .init(placeholder: (1760, 1152), image: UIImage(named: "test"))),
    .init(commentId: 10001, deleted: false, name: "Alice", permissions: [], postId: 10000, tags: [], text: "那就换个学生工作。校史馆讲解队要是招人可以去玩玩，应该挺有意义", type: .text, image: nil),
    .init(commentId: 10002, deleted: false, name: "Bob", permissions: [], postId: 10000, tags: [], text: "允", type: .image, image: .init(placeholder: (1760, 1152), image: UIImage(named: "test.long"))),
    .init(commentId: 10003, deleted: false, name: "Carol", permissions: [], postId: 10000, tags: [], text: "讲道理 这可以当作图灵测试", type: .image, image: .init(placeholder: (1760, 1152), image: UIImage(named: "test.phone")))
]
#endif
