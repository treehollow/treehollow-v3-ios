//
//  HoleContentView.swift
//  THU-Hole
//
//  Created by 梁业升 on 2021/1/13.
//

import SwiftUI

struct HoleContentView: View {
    // TODO: Add contents other than text
    
    var texts: [Text]
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(0..<texts.count) { index in
                // Set higher priority for top paragraphs
                texts[index]
                    .layoutPriority(Double(texts.count - index))
            }
                .layoutPriority(0)
        }
    }
}


#if DEBUG
struct CardContentView_Previews: PreviewProvider {
    static let testText: [Text] = [
        Text("树洞开源开发者寒假招募").textAttribute(type: .h2),
        Text("从1.11开始，T大树洞将进行下一代树洞的开发，开发进度预计为：") + Text("4周时间可行性验证与程序设计+2周时间集中开发代码+4周时间测试。").textAttribute(type: .bold),
        Text("我们将几乎从0开始进行本站Android、iOS开源客户端的开发，并对现有的Web版树洞进行升级。"),
        Text("我需要做什么？").textAttribute(type: .ol(1)).textAttribute(type: .h3),
        Text("参与本站的Android、iOS或Web开源客户端的开发。"),
        Text("我需要具备哪些能力？").textAttribute(type: .ol(2)).textAttribute(type: .h3),
        Text("对Android开发者：熟悉java，对Android开发有一定经验。").textAttribute(type: .ul),
        Text("对iOS开发者：熟悉swift，对iOS开发有一定经验。").textAttribute(type: .ul),
        Text("对Web开发者：熟悉react，对Web开发有一定经验。").textAttribute(type: .ul),
        Text("对以上开发语言有过接触，希望在实际开发环境中边学习边实践也可。").textAttribute(type: .ul),
        Text("投递方式").textAttribute(type: .ol(3)).textAttribute(type: .h3),
        Text("""
            邮箱投递： hr@thuhole.com
            邮件标题：【T大树洞开源开发者招募】
            邮件内容：请简要介绍一下你自己，如果有简历和代表作会更好。除此之外，如果你获得这个岗位，你初步的工作计划是什么，以及你愿意为之付出多少精力。\n
            """) + Text("我们将通过您的来信邮箱与您进行后续沟通交流。").textAttribute(type: .bold)

    ]
    static var previews: some View {
        HoleContentView(texts: testText)
    }
}
#endif
