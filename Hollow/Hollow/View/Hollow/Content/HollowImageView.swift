//
//  HollowImageView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/22.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct HollowImageView: View {
    @Binding var hollowImage: HollowImage?
    @State private var flash = false
    var body: some View {
        Group {
            if let hollowImage = self.hollowImage {
                if let image = hollowImage.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .animation(.default)
                } else {
                    Rectangle()
                        .foregroundColor(.uiColor(flash ? .systemFill : .tertiarySystemFill))
                        .aspectRatio(hollowImage.placeholder.width / hollowImage.placeholder.height, contentMode: .fit)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                                flash.toggle()
                            }
                        }
                }
            }
        }
    }
}

struct HollowImageView_Previews: PreviewProvider {
    static var previews: some View {
        HollowDetailView(postData: .constant(testPostData), presentedIndex: .constant(-1))
        HollowDetailView(postData: .constant(testPostData2), presentedIndex: .constant(-1))
        HollowImageView(hollowImage: .constant(.init(placeholder: (1760, 1152), image: UIImage(named: "test"))))
    }
}
