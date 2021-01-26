//
//  TimelineView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct TimelineView: View {
    @ObservedObject var viewModel: Timeline = .init()
    @State private var detailPresentedIndex = -1
    var body: some View {
        // TODO: Show refresh button
        CustomScrollView(refresh: { refresh in refresh = false }, content: {
            VStack(spacing: 0) {
                ForEach(0..<viewModel.posts.count) { index in
                    HollowTimelineCardView(postData: $viewModel.posts[index], viewModel: .init(voteHandler: { option in viewModel.vote(postId: viewModel.posts[index].postId, for: option)}))
                        .padding(.horizontal)
                        .padding(.bottom)
                        .onTapGesture {
                            detailPresentedIndex = index
                        }
                        // FIXME: Cannot present after presenting and dismissing menu!
                        .fullScreenCover(isPresented: .constant(detailPresentedIndex == index), content: {
                            HollowDetailView(postData: $viewModel.posts[index], presentedIndex: $detailPresentedIndex)
                        })
                }
            }
        })
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
