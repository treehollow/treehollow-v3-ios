//
//  HollowVoteContentView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/21.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

// TODO: UI logic after submitting vote (pressing `comfirm` button)
struct HollowVoteContentView: View {
    // FIXME: Change @State to @Binding after finish testing the standalone view
    @Binding var vote: Post.Vote
    // This var is to track which option is selected but not yet confirmed
    @State var voteButNotConfirmIndex = -1
    @ObservedObject var viewModel: HollowVoteContentViewModel
    // `voteCount` doesn't need to be marked @State to update the view since any changes to `vote` will cause the view to redraw and calculate this value again.
    // FIXME: We don't know how to animate the changes in the children if it is not marked @Binding in them.
    var voteCount: Int {
        var count = 0
        for voteData in vote.voteData {
            count += voteData.voteCount
        }
        return count
    }
    var body: some View {
        VStack(spacing: 12) {
            // The count of the options will not change, so we just use the count here.
            ForEach(0..<vote.voteData.count) { index in
                HStack {
                    Button(action: {
                        withAnimation(.default) {
                            self.voteButNotConfirmIndex = self.voteButNotConfirmIndex == index ? -1 : index
                        }
                    }) {
                        VoteBarView(voteData: $vote.voteData[index],
                                    totalNum: voteCount,
                                    // FIXME: Handle -1
                                    selected: vote.votedOption == vote.voteData[index].title)
                    }
                    // Disable the button when the user has voted
                    .disabled(vote.voteData[index].voteCount >= 0)
                    if vote.voteData[index].voteCount < 0 && voteButNotConfirmIndex == index {
                        Button(LocalizedStringKey("Confirm"), action: {
                            viewModel.voteHandler(vote.voteData[index].title)
                        })
                        .font(.plain)
                        .transition(.move(edge: .trailing))
                    }
                }
            }
        }
    }
    
    private struct VoteBarView: View {
        @Binding var voteData: Post.Vote.VoteData
        var totalNum: Int
        var selected: Bool
        var body: some View {
            HStack {
                Text(voteData.title)
                if selected {
                    Image(systemName: "checkmark")
                }
                Spacer()
                // Not displaying the vote result if not voted
                if voteData.voteCount >= 0 {
                    Text("\(voteData.voteCount)").bold()
                    Text(LocalizedStringKey("votes"))
                }
            }
            .font(.plain)
            .foregroundColor(.uiColor(.label))
            .padding(12)
            .padding(.horizontal, 7)
            .background(
                Rectangle()
                    .foregroundColor(
                        selected ? .uiColor(.systemGray4) : .uiColor(.systemGray5)
                    )
                    .overlay(
                        // TODO: Animation (from 0 to the proportion)
                        VotePortionRectangle(proportion: Double(
                                                voteData.voteCount >= 0
                                                    ? voteData.voteCount
                                                    : 0) / Double(totalNum)
                        )
                        .foregroundColor(.blue)
                    )
                    .clipShape(Capsule())
            )
        }
    }
    
    private struct VotePortionRectangle: Shape {
        var proportion: Double
        func path(in rect: CGRect) -> Path {
            let endX = rect.minX + rect.width * CGFloat(proportion)
            let minY = rect.minY + 0.9 * rect.height
            let firstPoint = CGPoint(x: rect.minX, y: minY)
            let secondPoint = CGPoint(x: endX, y: minY)
            let thirdPoint = CGPoint(x: endX, y: rect.maxY)
            let fourthPoint = CGPoint(x: rect.minX, y: rect.maxY)
            
            return Path { path in
                path.move(to: firstPoint)
                path.addLine(to: secondPoint)
                path.addLine(to: thirdPoint)
                path.addLine(to: fourthPoint)
                path.addLine(to: firstPoint)
            }
        }
    }
}

struct HollowVoteContentView_Previews: PreviewProvider {
    static var previews: some View {
        HollowVoteContentView(vote: .constant(.init(voted: true, votedOption: "赞成", voteData: [.init(title: "赞成", voteCount: 12), .init(title: "反对", voteCount: 121)])), viewModel: .init(voteHandler: { string in print("Selected option \(string)") }))
    }
}
