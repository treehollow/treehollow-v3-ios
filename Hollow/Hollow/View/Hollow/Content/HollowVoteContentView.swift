//
//  HollowVoteContentView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/21.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct HollowVoteContentView: View {
    var vote: VoteData
    var voteHandler: (String) -> Void
    var allowVote: Bool = true
    
    @State private var selectedButNotFinishIndex: Int = -1
    @State private var showProportion: Bool = false
    
    var body: some View {
        VStack(spacing: 10) {
            let totalVoteCount = vote.voteData.map({ $0.voteCount }).reduce(0, { $0 + $1 })
            // The count of the options will not change, so we just use the count here.
            ForEach(vote.voteData.indices, id: \.self) { index in
                if allowVote {
                    Button(action: {
                        withAnimation(.default) {
                            selectedButNotFinishIndex = index
                            voteHandler(vote.voteData[index].title)
                        }
                    }) {
                        return VoteBarView(voteData: vote.voteData[index], totalCount: totalVoteCount, selectedButNotFinish: selectedButNotFinishIndex == index, selected: vote.votedOption == vote.voteData[index].title, showProportion: showProportion)
                    }
                    // Disable the button when the user has voted
                    .disabled(vote.voteData[index].voteCount >= 0 || selectedButNotFinishIndex != -1)
                    .onTapGesture {
                        if !vote.voteData.isEmpty, vote.voteData[0].voteCount >= 0 {
                            withAnimation { showProportion.toggle() }
                        }
                    }

                } else {
                    // Not display the vote options as buttons
                    // specifically for WanderView.
                    VoteBarView(voteData: vote.voteData[index], totalCount: totalVoteCount, selectedButNotFinish: selectedButNotFinishIndex == index, selected: vote.votedOption == vote.voteData[index].title, showProportion: showProportion)
                }
            }
        }
    }
    
    
    // TODO: Vote proportion
    private struct VoteBarView: View {
        var voteData: VoteData.Data
        var totalCount: Int
        private var voted: Bool { voteData.voteCount >= 0 }
        var selectedButNotFinish: Bool
        var selected: Bool
        var showProportion: Bool
        
        @ScaledMetric(wrappedValue: 15, relativeTo: .body) var body15: CGFloat

        var body: some View {
            HStack {
                Text(voteData.title)
                    .layoutPriority(0)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                if selected {
                    Image(systemName: "checkmark")
                        .layoutPriority(0.1)
                }
                Spacer()
                // Not displaying the vote result if not voted
                if voted {
                    let percentage = Int(Double(100 * voteData.voteCount) / Double(totalCount))
                    let text = showProportion ?
                        percentage.string + (voteData.voteCount == 0 ? "" : "%") :
                        voteData.voteCount.string
                    
                    Text(text).bold()
                        .layoutPriority(1)
                }
                // Show spinner when submitting vote option
                if !voted && selectedButNotFinish {
                    Spinner(color: .hollowContentText, desiredWidth: 14)
                        .layoutPriority(1)
                }
            }
            .font(.system(size: body15))
            .lineLimit(1)
            .foregroundColor(selected ? .white : .uiColor(.label))
            .padding(10)
            .padding(.horizontal, 8)
            .background(
                LinearGradient.vertical(gradient: selected ? .hollowContentVote : .clear)
                    .opacity(selected && voteData.voteCount != totalCount ? 0.7 : 1)
                    .overlay(Group { if voted {
                        VotePortionRectangle(proportion: Double(voteData.voteCount) / Double(totalCount))
                            .foregroundColor(.hollowContentVoteGradient1)
                            .opacity(selected ? 1 : 0.3)
                            .opacity(voteData.voteCount == totalCount ? 0 : 1)
                    }})
            )
            .overlay(
                Group { if !selected {
                    LinearGradient.vertical(gradient: .hollowContentVote)
                        .clipShape(Capsule().stroke(style: .init(lineWidth: 3)))
                }}
            )
            .clipShape(Capsule())
        }
    }
    
        private struct VotePortionRectangle: Shape, Animatable {
            var proportion: Double
            func path(in rect: CGRect) -> Path {
                let endX = rect.minX + rect.width * CGFloat(proportion)
                let minY = rect.minY + 0 * rect.height
                let radius = rect.height / 2
                let firstPoint = CGPoint(x: rect.minX, y: minY)
                let secondPoint = CGPoint(x: endX - radius, y: minY)
                let fourthPoint = CGPoint(x: rect.minX, y: rect.maxY)
    
                return Path { path in
                    path.move(to: firstPoint)
                    path.addLine(to: secondPoint)
                    path.move(to: secondPoint)
                    path.addRelativeArc(center: CGPoint(x: secondPoint.x, y: rect.midY), radius: radius, startAngle: Angle(degrees: -90), delta: Angle(degrees: 180))
                    path.addLine(to: fourthPoint)
                    path.addLine(to: firstPoint)
                }
            }
            
            var animatableData: Double {
                get { proportion }
                set { proportion = newValue }
            }
        }
}

#if DEBUG
struct HollowVoteContentView_Previews: PreviewProvider {
    static var previews: some View {
        HollowVoteContentView(vote: .init(votedOption: "赞成", voteData: [.init(title: "赞成", voteCount: 4), .init(title: "反对", voteCount: 2)]), voteHandler: { string in print("Selected option \(string)") })
            .background(Color.black)
            .colorScheme(.dark)
    }
}
#endif
