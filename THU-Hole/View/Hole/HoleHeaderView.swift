//
//  HoleHeaderView.swift
//  THU-Hole
//
//  Created by 梁业升 on 2021/1/13.
//

import SwiftUI

struct HoleHeaderView: View {
    var configuration: HoleHeaderConfiguration
    @State var fullTextCopied = false
    var isContentHidden: Bool
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    guard !fullTextCopied else { return }
                    // TODO: fetch string
                    UIPasteboard.general.string = "Copied String"
                    withAnimation(.spring()) {
                        fullTextCopied = true
                    }
                    _ = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in
                        withAnimation(.spring()) { fullTextCopied = false }
                    })
                }, label: {
                    Text(fullTextCopied ? "已复制" : "#\(configuration.holeIndex)")
                        .headerSecondaryBoldText()
                        .animation(.spring())
                })
                .layoutPriority(100)
                .animation(.none)
                .disabled(fullTextCopied || isContentHidden)
                Text(configuration.timeString)
                    .headerSecondaryText()
                    .foregroundColor(.gray)
                Spacer()
                if configuration.compact {
                    if isContentHidden {
                        // TODO: localization
                        Text("已隐藏")
                            .headerSecondaryBoldText()
                            .foregroundColor(.gray)
                    } else {
                        HStack {
                            CustomLabel(title: "\(configuration.starredNumber)", systemImageName: "star", spacing: 2)
                            CustomLabel(title: "\(configuration.commentNumber)", systemImageName: "bubble.left", spacing: 2)
                        }
                        .font(.footnote)
                        .foregroundColor(.gray)
                    }
                } else {
                    Button(action: {
                        // TODO: add report action here
                    }, label: {
                        HStack(spacing: 2) {
                            Image(systemName: "flag.fill")
                            Text("举报")
                        }
                        .animation(.spring())
                        .font(.footnote)
                        .foregroundColor(.red)
                    })
                    .animation(.none)
                    .layoutPriority(90)
                }
            } // HStack
            
            // check here to avoid additional spacing
            if configuration.tags.count != 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(0..<configuration.tags.count) { index in
                            TagView(type: configuration.tags[index])
                                .fixedSize()
                        }
                    }
                }
            }
        }
    }
}

extension HoleHeaderView {
    struct TagView: View {
        enum TagType: CustomStringConvertible {
            
            // TODO: add more types
            case report, sex, uncomfortable, rumor
            var description: String {
                switch self {
                case .report: return "举报较多"
                case .sex: return "性相关"
                case .uncomfortable: return "令人不适"
                case .rumor: return "未经证实的传闻"
                }
            }

            var imageName: String {
                switch self {
                case .report: return "exclamationmark.triangle"
                case .sex: return ""
                case .uncomfortable: return ""
                case .rumor: return ""
                }
            }
        }
        var type: TagType
        var body: some View {
            let hasImage = type.imageName != ""
            HStack(spacing: hasImage ? 3 : 0) {
                Image(systemName: type.imageName)
                Text(type.description)
            }
            .foregroundColor(.white)
            .font(.system(size: 13, weight: .semibold))
            .padding(.vertical, 3)
            .padding(.horizontal, 6)
            .background(Color.blue)
            .cornerRadius(6)
        }
    }
}

extension Text {
    func headerSecondaryText() -> some View {
        return self
            .font(.footnote)
            .lineLimit(1)
    }
    
    func headerSecondaryBoldText() -> some View {
        return self
            .bold()
            .headerSecondaryText()
    }

}

#if DEBUG
struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HoleHeaderView(configuration: .init(holeIndex: 181826, timeString: "大约22小时之前 1-11 21:35:25", tags: [.report, .sex, .uncomfortable], compact: true, starredNumber: 21, commentNumber: 12), isContentHidden: true)
        HoleHeaderView(configuration: .init(holeIndex: 181826, timeString: "大约22小时之前 1-11 21:35:25", tags: [], compact: true, starredNumber: 21, commentNumber: 12), isContentHidden: false)

    }
}
#endif
