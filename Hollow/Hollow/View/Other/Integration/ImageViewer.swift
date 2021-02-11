//
//  ImageViewer.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/11.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import ImageScrollView

struct ImageViewer: View {
    var image: UIImage
    var footnote: String?
    
    @Binding var presented: Bool
    @State private var lineLimit: Int? = 1
    
    @Environment(\.colorScheme) var colorScheme
    
    @ScaledMetric(wrappedValue: 20, relativeTo: .body) var body20: CGFloat
    
    var body: some View {
        ZStack {
            ImageViewerWrapper(image: image, presented: $presented)
                .ignoresSafeArea()
            if let footnote = footnote {
                Text(footnote)
                    .font(.footnote)
                    .padding(.horizontal)
                    .padding(.top)
                    .leading()
                    .blurBackground()
                    .lineLimit(lineLimit)
                    .onTapGesture { withAnimation {
                        lineLimit = lineLimit == nil ? 1 : nil
                    }}
                    .bottom()
            }
            Button(action: { presented = false }) {
                Text("Done")
                    .bold()
                    .foregroundColor(.primary)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 6)
                    .blurBackground()
                    .cornerRadius(8)
            }
            .padding(.horizontal)

            .top()
            .trailing()

        }

        .blurBackground()
        .background(
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )

    }
}

struct ImageViewerWrapper: UIViewRepresentable {
    var image: UIImage
    var presented: Binding<Bool>
    func makeUIView(context: Context) -> ImageScrollView {
        let view = ImageScrollView()
        view.setup()
        view.display(image: image)
        view.maxScaleFromMinScale = 4
        return view
    }
    
    func updateUIView(_ uiView: ImageScrollView, context: Context) {
//        uiView.display(image: image)
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: ImageViewerWrapper
        init(_ parent: ImageViewerWrapper) {
            self.parent = parent
        }
    }
    
}

#if DEBUG
struct ImageViewer_Previews: PreviewProvider {
    static var previews: some View {
        ImageViewer(image: UIImage(named: "test.2")!, footnote: testPostData.text, presented: .constant(true))
    }
}
#endif
