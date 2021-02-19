//
//  TestPostData.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/26.
//  Copyright © 2021 treehollow. All rights reserved.
//

#if DEBUG
import SwiftUI
let testText = "SwiftUI\nSwiftUI 是一种创新、简洁的编程方式，通过 Swift 的强大功能，在所有 Apple 平台上构建用户界面。借助它，您只需一套工具和 API，即可创建面向任何 Apple 设备的用户界面。SwiftUI 采用简单易懂、编写方式自然的声明式 Swift 语法，可无缝支持新的 Xcode 设计工具，让您的代码与设计保持高度同步。SwiftUI 原生支持“动态字体”、“深色模式”、本地化和辅助功能——第一行您写出的 SwiftUI 代码，就已经是您编写过的、功能最强大的 UI 代码。"

let testText2 = "声明式语法SwiftUI 采用声明式语法，您只需声明用户界面应具备的功能即可。例如，您可以写明您需要一个由文本栏组成的项目列表，然后描述各个栏位的对齐方式、字体和颜色。您的代码比以往更加简单直观和易于理解，可以节省您的时间和维护工作。"

let testText3 = "设计工具  \nXcode 11 包含直观的设计新工具，使用拖放操作就能轻松地通过SwiftUI 构建界面。当您在设计画布中操作时，您的每一项编辑都会与相邻编辑器中的代码保持完全同步。在您键入时代码会立即以预览形式显示，您对预览进行的任何更改会立即反映在您的代码中。Xcode 会即时重新编译您的更改，并将它们插入到 app 的运行版本中，供您随时进行查看和编辑。"

let testPostData: PostData = .init(attention: true, deleted: false, likeNumber: 21, permissions: [], postId: 198431, replyNumber: 12, tag: "", text: testText, hollowImage: .init(placeholder: (1760, 1152), image: UIImage(named: "test")), vote: .init(voted: true, votedOption: "好", voteData: [
    .init(title: "好", voteCount: 214),
    .init(title: "不好", voteCount: 17)
]), comments: Array.init(repeating: testComments[0], count: 500))

let testPostData2: PostData = .init(attention: true, deleted: false, likeNumber: 21, permissions: [], postId: 198432, replyNumber: 12, tag: "", text: testText2,  hollowImage: .init(placeholder: (1760, 1152), image: UIImage(named: "test.2")), vote: .init(voted: true, votedOption: "好", voteData: [
    .init(title: "好", voteCount: 62),
    .init(title: "不好", voteCount: 3)
]), comments: testComments)

let testPostData3: PostData = .init(attention: true, deleted: false, likeNumber: 21, permissions: [], postId: 198433, replyNumber: 12, tag: "", text: testText3,  hollowImage: .init(placeholder: (1760, 1152), image: UIImage(named: "test.3")), vote: nil, comments: testComments)

let testPostData4: PostData = .init(attention: true, deleted: false, likeNumber: 21, permissions: [], postId: 198434, replyNumber: 12, tag: "", text: testText3,  hollowImage: nil, vote: nil, comments: testComments)

// Compressing raw image, simulating the real circumstances
let testPostDataCompressedImage: PostData = .init(attention: true, deleted: false, likeNumber: 21, permissions: [], postId: 198432, replyNumber: 12, tag: "", text: testText2,  hollowImage: .init(placeholder: (1760, 1152), image: UIImage(data: UIImage(named: "test.2")!.jpegData(compressionQuality: 0.5)!)!), vote: .init(voted: true, votedOption: "好", voteData: [
    .init(title: "好", voteCount: 62),
    .init(title: "不好", voteCount: 3)
]), comments: testComments)

let testPostDataNoExtraComponents: PostData = .init(attention: true, deleted: false, likeNumber: 21, permissions: [], postId: 198433, replyNumber: 12, tag: "", text: testText3,  hollowImage: nil, vote: nil, comments: testComments)

let testPosts = [
    testPostData,
    testPostData2,
    testPostData3,
    testPostData4
]


let testPostDataWrapper: PostDataWrapper = .init(post: testPostData, citedPost: .init(postId: testPostData2.postId, text: testPostData2.text))
let testPostDataWrapper2: PostDataWrapper = .init(post: testPostData2, citedPost: .init(postId: testPostData.postId, text: testPostData.text))
let testPostDataWrapper3: PostDataWrapper = .init(post: testPostData3, citedPost: .init(postId: testPostData.postId, text: testPostData2.text))
let testPostDataWrapper4: PostDataWrapper = .init(post: testPostData4, citedPost: .init(postId: testPostData.postId, text: testPostData2.text))
let testPostDataWrapperNoExtraComponents: PostDataWrapper = .init(post: testPostDataNoExtraComponents, citedPost: .init(postId: testPostData.postId, text: testPostData2.text))

let testPostWrappers = [testPostDataWrapper, testPostDataWrapper2, testPostDataWrapper3, testPostDataWrapper4]
#endif
