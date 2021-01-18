//
//  HollowContentView.swift
//  Hollow
//
//  Created on 2021/1/17.
//

import SwiftUI

struct HollowContentView: View {
    @Binding var text: String
    @Binding var hollowImage: HollowImage?
    // TODO: cite content
    var body: some View {
        VStack {
            rawImageView()
                .cornerRadius(8)
            Text(text)
                .font(.plain)
        }
    }
    
    func rawImageView() -> AnyView {
        if let hollowImage = self.hollowImage {
            if let image = hollowImage.image {
                return AnyView(Image(uiImage: image))
            } else {
                return AnyView(ImagePlaceholderView(placeholder: hollowImage.placeholder))
            }
        }
        return AnyView(EmptyView())
    }
    
    struct ImagePlaceholderView: View {
        var placeholder: (CGFloat, CGFloat)
        var body: some View {
            // TODO: Add visual effects
            return Rectangle()
                .foregroundColor(Color(UIColor.systemGray5))
                .aspectRatio(placeholder.0 / placeholder.1, contentMode: .fill)
        }
    }
}

struct HollowContentView_Previews: PreviewProvider {
    static let text = "The time it would take to close the Health and Survival gender gap remains undefined. It is the smallest gap and has remained substantially stable over the years and can be considered virtually closed in most countries. However, it won’t be fully closed as long as specific issues remain in some of the most populous countries (e.g. China and India). WEF这段话在内涵什么？"
    static var previews: some View {
        ScrollView {
            HollowContentView(text: .constant(text), hollowImage: .constant(.init(placeholder: (100, 150), image: nil)))
                .padding()
        }
    }
}
