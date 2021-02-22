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
    @State private var scale: CGFloat = 0
    @State private var showActionSheet = false
    @State private var savePhotoMessage: (title: String, message: String)?
    @State private var safeAreaInsets: EdgeInsets = .init()
    
    @Environment(\.colorScheme) var colorScheme
    
    @ScaledMetric(wrappedValue: 20, relativeTo: .body) var body20: CGFloat
    @ScaledMetric(wrappedValue: 16, relativeTo: .body) var body16: CGFloat
    
    var body: some View {
        ZStack {
            ImageScrollViewWrapper(image: image, presented: $presented, scale: $scale, showActionSheet: $showActionSheet)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                Button(action: { presented = false }) {
                    Text("Done")
                        .font(.system(size: body16, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 6)
                        .blurBackground()
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .trailing()
                
                Spacer()

                if let footnote = self.footnote, footnote != "" {
                    Text(footnote)
                        .font(.footnote)
                        .padding(.horizontal)
                        .padding(.top)
                        .conditionalPadding(safeAreaInsets: safeAreaInsets, bottom: nil)
                        .leading()
                        .blurBackground()
                        .lineLimit(lineLimit)
                        .onTapGesture { withAnimation {
                            lineLimit = lineLimit == nil ? 1 : nil
                        }}
                }

            }
            
            // Hide the components when overlapping
            .opacity(scale > 2 ? 0 : 1)
        }

        .blurBackground(style: .systemUltraThinMaterial)
        .background(
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(title: Text("Image"), buttons: [
                .cancel(),
                .default(Text("Save to Photos"), action: {
                    let saver = ImageSaver(finishHandler: { error in
                        savePhotoMessage =
                            (error?.localizedDescription ?? "Successfully saved to Photos", "")
                    })
                    saver.saveImage(image)
                })
            ])
        }
        
        .modifier(ErrorAlert(errorMessage: $savePhotoMessage))

        .modifier(GetSafeAreaInsets(insets: $safeAreaInsets))
    }
}

struct ImageScrollViewWrapper: UIViewRepresentable {
    var image: UIImage
    var presented: Binding<Bool>
    var scale: Binding<CGFloat>
    var showActionSheet: Binding<Bool>
    func makeUIView(context: Context) -> ImageScrollView {
        let view = ImageScrollView()
        view.setup()
        view.display(image: image)
        view.maxScaleFromMinScale = 4
        view.imageScrollViewDelegate = context.coordinator
        view.addGestureRecognizer(
            UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.onLongPresss))
        )
        return view
    }
    
    func updateUIView(_ uiView: ImageScrollView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, ImageScrollViewDelegate {
        var parent: ImageScrollViewWrapper
        init(_ parent: ImageScrollViewWrapper) {
            self.parent = parent
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            withAnimation {
                parent.scale.wrappedValue = scrollView.zoomScale / scrollView.minimumZoomScale
            }
        }
        
        func imageScrollViewDidChangeOrientation(imageScrollView: ImageScrollView) {
            
        }
        
        @objc func onLongPresss() {
            parent.showActionSheet.wrappedValue = true
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
