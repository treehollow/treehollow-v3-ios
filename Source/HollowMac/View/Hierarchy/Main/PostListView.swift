////
////  PostListView.swift
////  HollowMac
////
////  Created by 梁业升 on 2021/4/25.
////  Copyright © 2021 treehollow. All rights reserved.
////
//
//import SwiftUI
//
//struct PostListView: View {
//    @ObservedObject var store: PostListRequestStore
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}
//
//struct PostListView_Previews: PreviewProvider {
//    static let posts: [PostDataWrapper] = [
//        .init(post: .init(attention: true, deleted: false, likeNumber: 102, permissions: [.delete], postId: 300123, replyNumber: 17, timestamp: Date(), tag: "HollowMac", text: "HollowMac[49374:1454326] [connection] nw_read_request_report [C2] Receive failed with error \"Connection reset by peer\"", hollowImage: .init(placeholder: (1000, 400), image: nil, imageURL: ""), vote: .init(votedOption: "", voteData: [.init(title: "Option 1", voteCount: -1), .init(title: "Option 2", voteCount: -1)]), comments: [], loadingError: nil, citedPostId: nil, hasURL: false, hasCitedNumbers: false, hash: 102123, colorIndex: 0), citedPost: nil)
//    ]
//    static var previews: some View {
//        PostListView(store: .init(type: .postList))
//    }
//}
