//
//  HollowWidget.swift
//  HollowWidget
//
//  Created by liang2kl on 2021/5/21.
//  Copyright © 2021 treehollow. All rights reserved.
//

import WidgetKit
import SwiftUI
import Defaults

struct Provider: TimelineProvider {
    func fetchPosts(completion: @escaping ([PostData]) -> Void) {
        guard let config = Defaults[.hollowConfig],
              let token = Defaults[.accessToken] else {
            completion([])
            return
        }
        let request = SearchRequest(configuration: .init(apiRoot: config.apiRootUrls.first!, token: token, keywords: config.searchTrending, page: 1, includeComment: false))
        request.performRequest(completion: { result, error in
            guard let result = result else {
                switch error {
                // Only show no posts when token expired
                case .tokenExpiredError: completion([])
                default: break
                }
                return
            }
            completion(result.map({ $0.post }))
        })
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), posts: [], isPlaceholder: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let completion: ([PostData]) -> Void = { result in
            let entry = SimpleEntry(date: Date(), posts: result, isPlaceholder: false)
            completion(entry)
            Defaults[.lastLoadDate] = Date()
        }
        let minInterval = 20.0
        let lastLoadDate = Defaults[.lastLoadDate] ?? .distantPast
        if Date().timeIntervalSince1970 - lastLoadDate.timeIntervalSince1970 > minInterval {
            fetchPosts(completion: completion)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + minInterval) {
                let lastLoadDate = Defaults[.lastLoadDate] ?? .distantPast
                if Date().timeIntervalSince1970 - lastLoadDate.timeIntervalSince1970 > minInterval {
                    fetchPosts(completion: completion)
                }
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(in: context, completion: { entry in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        })
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let posts: [PostData]
    let isPlaceholder: Bool
}

struct HollowWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 3) {
            if entry.isPlaceholder {
                ForEach(1..<7) { rank in
                    HStack {
                        Text(rank.string)
                            .fontWeight(.heavy)
                            .frame(minWidth: 20)
                        RoundedRectangle(cornerRadius: 5)
                            .padding(.vertical, 3)
                            .padding(.trailing, 5)
                    }
                    .foregroundColor(Color(UIColor.secondarySystemFill))
                }
            } else if entry.posts.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Text("WIDGET_EMPTY_LABEL")
                        .fontWeight(.bold)
                        .foregroundColor(.contentText)
                    Spacer()
                }
                Text("WIDGET_EMPTY_MSG")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 50)
                    .padding(.top, 20)
                Spacer()
            } else {
                ForEach(entry.posts.indices.prefix(6), id: \.self) { index in
                    HollowView(post: entry.posts[index], rank: index + 1)
                        .layoutPriority(Double(1000 - index))
                        .frame(maxHeight: .infinity)
                }
            }
        }
        .padding(10)
        .background(Color.background)
    }
    
    struct HollowView: View {
        var post: PostData
        var rank: Int
        
        let foldTags = Defaults[.hollowConfig]?.foldTags ?? []

        var body: some View {
            Link(destination: URL(string: "Hollow://post-#\(post.postId.string)")!) {
                HStack {
                    Text(rank.string)
                        .fontWeight(.heavy)
                        .foregroundColor(.gradient1)
                        .frame(minWidth: 20)
                    if let tag = post.tag, foldTags.contains(tag) {
                        // Tag
                        Text(tag)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.gradient2)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    } else {
                        if post.text != "" {
                            Text("\(post.text.removeLineBreak())")
                        }
                        if post.hollowImage != nil {
                            Text(Image(systemName: "photo"))
                        }
                    }
                    Spacer()
                    Text("#\(post.postId.string)")
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                .padding(.trailing, 5)
            }
            .lineLimit(1)
            .foregroundColor(.contentText)
            .font(.system(size: 14, design: .monospaced))
        }
        
    }
}

@main
struct HollowWidget: Widget {
    let kind: String = "HollowWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HollowWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("WIDGET_DISPLAY_NAME")
        .description("WIDGET_DESCRIPTION")
        .supportedFamilies([.systemMedium])
    }
}
