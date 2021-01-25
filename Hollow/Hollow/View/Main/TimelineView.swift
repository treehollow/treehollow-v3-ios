//
//  TimelineView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct TimelineView: View {
    @ObservedObject var viewModel: TimelineViewModel = .init()
    var body: some View {
        CustomScrollView(refresh: { refresh in refresh = false }, content: {
            VStack(spacing: 0) {
                ForEach(0..<viewModel.posts.count) { index in
                    HollowTimelineCardView(postData: $viewModel.posts[index], viewModel: .init(voteHandler: { option in viewModel.vote(postId: viewModel.posts[index].postId, for: option)}))
                        .padding(.horizontal)
                        .padding(.bottom)
                }
            }
        })
//                ScrollView {
//                    VStack(spacing: 0) {
//                        ForEach(0..<viewModel.posts.count) { index in
//                            HollowTimelineCardView(postData: $viewModel.posts[index], viewModel: .init(voteHandler: { option in viewModel.vote(postId: viewModel.posts[index].postId, for: option)}))
//                                .padding(.horizontal)
//                                .padding(.bottom)
//                        }
//                    }
//                }

    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            TimelineView()
        }
    }
}
