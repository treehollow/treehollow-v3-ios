//
//  HoleCardView.swift
//  THU-Hole
//
//  Created by 梁业升 on 2021/1/13.
//

import SwiftUI

struct HoleCardView: View {
    @State var fullTextCopied = false
    var configuration: HoleCardConfiguration
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                HoleHeaderView(configuration: configuration.headerConfiguration, isContentHidden: !configuration.showHoleContent)
                    .padding(.bottom, configuration.showHoleContent && configuration.headerConfiguration.tags.count != 0 ? 5 : 0)
                if configuration.showHoleContent {
                    HoleContentView(texts: configuration.texts)
                }
            }
            .card()
            .padding(.horizontal)

            // long press actions
            .contextMenu(menuItems: {
                // TODO: Check if it has starred
                Button(action: {
                    // action for star or unstar
                }) {
                    CustomLabel(title: "收藏", systemImageName: "star")
                }
                
                // TODO: add more actions
            })
            if let commentConfigurations = configuration.commentConfigurations, commentConfigurations.count > 0 {
                HoleCommentScrollView(configurations: commentConfigurations)
                    .offset(x: 0, y: -20)
            }
        }
    }
    
    struct HoleCommentScrollView: View {
        var configurations: [HoleCommentConfiguration]
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    Spacer(minLength: 100)
                    ForEach(0..<configurations.count) { index in
                        HoleCommentCardView(configuration: configurations[index])
                            .padding(6)
                            .shadow(radius: 4)
                    }
                }
            }
        }
    }
}

extension View {
    func card() -> some View {
        return self
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(15)
            .contentShape(RoundedRectangle(cornerRadius: 15))
    }
}

#if DEBUG
struct CardView_Previews: PreviewProvider {
    static let configuration: HoleHeaderConfiguration = .init(holeIndex: 181826, timeString: "大约22小时之前", tags: [.sex, .report, .uncomfortable, .rumor], compact: true, starredNumber: 21, commentNumber: 12)
    static let testText: [Text] = [
        Text("树洞开源开发者寒假招募").textAttribute(type: .h2),
        Text("从1.11开始，T大树洞将进行下一代树洞的开发，开发进度预计为：") + Text("4周时间可行性验证与程序设计+2周时间集中开发代码+4周时间测试。").textAttribute(type: .bold) + Text("\n我们将几乎从0开始进行本站Android、iOS开源客户端的开发，并对现有的Web版树洞进行升级。"),
        Text("我需要做什么？").textAttribute(type: .ol(1)).textAttribute(type: .h3),
        Text("参与本站的Android、iOS或Web开源客户端的开发。"),
        Text("我需要具备哪些能力？").textAttribute(type: .ol(2)).textAttribute(type: .h3),
        Text("对Android开发者：熟悉java，对Android开发有一定经验。\n").textAttribute(type: .ul) +
            Text("对iOS开发者：熟悉swift，对iOS开发有一定经验。\n").textAttribute(type: .ul) +
            Text("对Web开发者：熟悉react，对Web开发有一定经验。\n").textAttribute(type: .ul) +
            Text("对以上开发语言有过接触，希望在实际开发环境中边学习边实践也可。").textAttribute(type: .ul),
    ]

    static var previews: some View {
        var newConfig = configuration
        newConfig.compact = false
        newConfig.tags = []
        return ScrollView {
            VStack(spacing: 0) {
                HoleCardView(configuration: .init(headerConfiguration: newConfig, texts: testText, commentConfigurations: [
                    .init(headerConfiguration: .init(holeIndex: 881840, timeString: "2天之前 1-11 21:41:33", compact: true), texts: [Text("支持！")]),
                    .init(headerConfiguration: .init(holeIndex: 881840, timeString: "2天之前 1-11 21:41:33", compact: true), texts: [Text("支持！")]),
                    .init(headerConfiguration: .init(holeIndex: 881840, timeString: "2天之前 1-11 21:41:33", compact: true), texts: [Text("支持！")]),
                    .init(headerConfiguration: .init(holeIndex: 881840, timeString: "2天之前 1-11 21:41:33", compact: true), texts: [Text("支持！")])
                ]))
                    .padding(.bottom)
                HoleCardView(configuration: .init(headerConfiguration: configuration, texts: testText, commentConfigurations: []))
                    .padding(.bottom)
                HoleCardView(configuration: .init(headerConfiguration: newConfig, texts: testText, commentConfigurations: [
                    .init(headerConfiguration: .init(holeIndex: 881840, timeString: "2天之前 1-11 21:41:33", compact: true), texts: [Text("支持！")]),
                    .init(headerConfiguration: .init(holeIndex: 881840, timeString: "2天之前 1-11 21:41:33", compact: true), texts: [Text("支持！")]),
                    .init(headerConfiguration: .init(holeIndex: 881840, timeString: "2天之前 1-11 21:41:33", compact: true), texts: [Text("支持！")]),
                    .init(headerConfiguration: .init(holeIndex: 881840, timeString: "2天之前 1-11 21:41:33", compact: true), texts: [Text("支持！")])
                ]))
                    .padding(.bottom)
            }
        }
    }
}
#endif
