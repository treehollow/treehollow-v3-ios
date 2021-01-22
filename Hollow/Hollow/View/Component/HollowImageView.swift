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
    var body: some View {
        rawImageView()
    }
    func rawImageView() -> AnyView {
        if let hollowImage = self.hollowImage {
            if let image = hollowImage.image {
                return AnyView(
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .animation(.default)
                )
            } else {
                return AnyView(
                    ImagePlaceholderView(placeholder: hollowImage.placeholder)
                        .animation(.default)
                )
            }
        }
        return AnyView(EmptyView())
    }
    
    private struct ImagePlaceholderView: View {
        var placeholder: (width: CGFloat, height: CGFloat)
        var body: some View {
            // TODO: Add visual effects
            return Rectangle()
                .foregroundColor(Color(UIColor.systemGray5))
                .aspectRatio(placeholder.width / placeholder.height, contentMode: .fit)
        }
    }
    
}

struct HollowImageView_Previews: PreviewProvider {
    static var previews: some View {
        HollowImageView(hollowImage: .constant(.init(placeholder: (1760, 1152), image: UIImage(named: "test"))))
    }
}
