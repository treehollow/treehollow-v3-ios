//
//  TestCommentData.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

#if DEBUG
import SwiftUI

let testComments: [CommentData] = [
//    .init(commentId: 10000, deleted: false, name: "Alice", permissions: [], postId: 10000, tags: [], text: "", type: .image, image: .init(placeholder: (1760, 1152), image: UIImage(named: "test.comment"))),
    .init(commentId: 10001, deleted: false, name: "Alice", permissions: [], postId: 10000, tags: [], text: "动态替换。Swift 编译器和运行时已全面嵌入到 Xcode 中，您可以随时构建和运行您的 app。您看到的设计画布不仅仅是近似用户界面——它就是您实时运行的 app。此外，借助 Swift 中新推出的“动态替换”功能，Xcode 可以直接在实时运行的 app 中替换编辑后的代码。  \n.init(font: .system(size: 16), paragraphSpacing: 3)", type: .text, image: nil),
    .init(commentId: 10002, deleted: false, name: "Bob", permissions: [], postId: 10000, tags: [], text: "预览。您现在可以为任何 SwiftUI 视图创建一个或多个预览来获取样本数据。用户能看见的任何内容 (例如大字体、本地化或深色模式)，你几乎都能配置。预览也可以显示您的 UI 在任何设备和方向上的呈现效果。", type: .image, image: .init(placeholder: (1760, 1152), image: UIImage(named: "test.comment.2"))),
    .init(commentId: 10003, deleted: false, name: "Carol", permissions: [], postId: 10000, tags: [], text: "这种声明式风格甚至适用于动画等复杂的概念。只需几行代码，就能轻松地向几乎任何控件添加动画并选择一系列即时可用的特效。在运行时，系统会处理所有必要的步骤和中断因素，来保证您的代码流畅运行、保持稳定。实现动画效果是如此简单，您还能探索新的方式让 app 更生动出彩。", type: .image, image: .init(placeholder: (1760, 1152), image: nil)),
    .init(commentId: 10004, deleted: false, name: "Dave", permissions: [], postId: 10000, tags: [], text: "Apple 的 app 经济生态在全球提供了数以百万计的技术类工作。无论您是刚踏入职场的新人，还是经验丰富的开发人员或企业家，都能利用免费的资源来获取相应技能，以帮助您在不断增长的 Apple app 经济生态中获得成功。(英文页面)", type: .image, image: .init(placeholder: (1760, 1152), image: UIImage(named: "test.comment.3"))),
    .init(commentId: 10005, deleted: false, name: "Dave", permissions: [], postId: 10000, tags: [], text: "macOS Big Sur 将世界领先前沿的操作系统提升至功能更强大、外观更绝美的全新高度。在全新的界面上，让您的 app 更显精美绝伦。新的小组件功能和新的小组件库可帮助您为用户带来更有价值、更好的体验。借助新的工具、模型、训练性能和 API，您现在能更轻松且广泛地在 app 中借助机器学习来添加智能功能。您还可以使用 Mac Catalyst 为 iPad app 创建功能更强大的 Mac 版本。现在，您更能轻松地将扩展带到 Safari，甚至是 App Store 上。", type: .image, image: .init(placeholder: (1760, 1152), image: UIImage(named: "test.comment.5")))
]
#endif
