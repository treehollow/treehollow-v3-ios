//
//  WanderView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI
import WaterfallGrid

struct WanderView: View {
    @ObservedObject var viewModel: Wander = .init()
    
    var body: some View {
        ScrollView {
            WaterfallGrid((0..<viewModel.posts.count), id: \.self) { index in
                HollowWanderCardView(postData: $viewModel.posts[index])
            }
            .gridStyle(columns: 2, spacing: 15, animation: nil)
            .padding(.horizontal, 15)
            .background(Color.background)
        }
    }
}

struct WanderView_Previews: PreviewProvider {
    static var previews: some View {
        WanderView()
    }
}
