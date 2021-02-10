//
//  ImageViewer.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/10.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct ImageViewer: View {
    @State var scale: CGFloat = 1
    @State var lastScale: CGFloat = 1
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            Image("test")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .horizontalCenter()
                .verticalCenter()
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = value
                        }
                        .onEnded { value in
                            lastScale = value
                        }
                )
        }
    }
}

struct ImageViewer_Previews: PreviewProvider {
    static var previews: some View {
        ImageViewer()
    }
}
