//
//  ImageViewer.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/11.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import ImageScrollView
import Combine

struct ImageViewer: View {
    var image: UIImage
    var footnote: String?
    
    @Binding var presented: Bool
    @State private var lineLimit: Int? = 1
    @State private var scale: CGFloat = 0
    @State private var showActionSheet = false
    @State private var savePhotoMessage: (title: String, message: String)?
    @State private var safeAreaInsets: EdgeInsets = .init()
    @State private var dragRelativeOffset: CGFloat = 0
    
    @State private var shouldDismiss = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var selfDismiss = false
    
    private let dismissScaleThreshold: CGFloat = 0.115
    
    var body: some View {
        ZStack {
            ImageScrollViewWrapper(image: image, presented: $presented, scale: $scale, showActionSheet: $showActionSheet, dragRelativeOffset: $dragRelativeOffset, selfDismiss: selfDismiss, didEndDragging: {
                if shouldDismiss { dismiss() }
            })
            .ignoresSafeArea()
            VStack(spacing: 0) {
                
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
        
        .background(Color.black.ignoresSafeArea().opacity(max(1 - Double(dragRelativeOffset), 0)))
        
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(title: Text("IMAGEVIEWER_ACTION_SHEET_TITLE"), buttons: [
                .cancel(),
                .default(Text("IMAGEVIEW_SAVE_PHOTO_BUTTON"), action: {
                    let saver = ImageSaver(finishHandler: { error in
                        savePhotoMessage =
                            (error?.localizedDescription ?? NSLocalizedString("IMAGEVIEW_SAVE_IMAGE_SUCCESS_ALERT_TITLE", comment: ""), "")
                    })
                    saver.saveImage(image)
                })
            ])
        }
        
        .onChange(of: dragRelativeOffset, perform: { offset in
            if offset > dismissScaleThreshold {
                if !shouldDismiss {
                    shouldDismiss = true
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            } else {
                if shouldDismiss {
                    shouldDismiss = false
                }
            }
        })
        
        .modifier(ErrorAlert(errorMessage: $savePhotoMessage))
        
        .modifier(GetSafeAreaInsets(insets: $safeAreaInsets))
        .statusBar(hidden: true)
    }
    
    func dismiss() {
        if selfDismiss { dismissSelf() }
        presented = false
    }
}

struct ImageScrollViewWrapper: UIViewRepresentable {
    var image: UIImage
    var presented: Binding<Bool>
    var scale: Binding<CGFloat>
    var showActionSheet: Binding<Bool>
    var dragRelativeOffset: Binding<CGFloat>
    var selfDismiss: Bool
    var didEndDragging: () -> Void
    
    func makeUIView(context: Context) -> ImageScrollView {
        let view = ImageScrollView()
        view.setup()
        view.display(image: image)
        view.maxScaleFromMinScale = 4
        view.imageScrollViewDelegate = context.coordinator
        view.alwaysBounceVertical = true
        view.alwaysBounceHorizontal = true
        view.decelerationRate = .normal
        view.addGestureRecognizer(
            UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.onLongPresss))
        )
        view.panGestureRecognizer.addTarget(context.coordinator, action: #selector(context.coordinator.panGestureDidPan))
        
        view.publisher(for: \.contentOffset)
            .dropFirst()
            .sink(receiveValue: { _ in
                guard !view.isZooming && context.coordinator.didPan else { return }
                let contentOffset = view.contentOffset
                let contentSize = view.contentSize
                let contentInset = view.adjustedContentInset
                let frameSize = view.frame.size
                
                let leftTranslation = contentInset.left - contentOffset.x
                let rightTranslation = contentOffset.x + frameSize.width - contentInset.right - contentSize.width
                let topTranslation = -contentOffset.y - contentInset.top
                var bottomTranslation = contentOffset.y + frameSize.height - contentInset.bottom - contentSize.height
                
                var xOffset: CGFloat = 0
                var yOffset: CGFloat = 0
                if leftTranslation > 0 {
                    xOffset = leftTranslation / frameSize.width
                }
                
                if rightTranslation > 0 {
                    xOffset = max(xOffset, rightTranslation / frameSize.width)
                }
                
                if contentSize.height < frameSize.height {
//                    topTranslation += (frameSize.height - contentSize.height) / 2
                    bottomTranslation -= (frameSize.height - contentSize.height)
                }
                
                if topTranslation > 0 {
                    yOffset = topTranslation / frameSize.width
                }
                
                if bottomTranslation > 0 {
                    yOffset = max(yOffset, bottomTranslation / frameSize.width)
                }
                guard xOffset != 1 && yOffset != 1 else { return }
                yOffset = min(1, yOffset)
                print(leftTranslation)
                print(rightTranslation)
                print(topTranslation)
                print(bottomTranslation, "\n")
                

                DispatchQueue.main.async {
                    dragRelativeOffset.wrappedValue = sqrt(xOffset * xOffset + yOffset * yOffset)
                }
            })
            .store(in: &context.coordinator.cancellables)
        return view
    }
    
    func updateUIView(_ uiView: ImageScrollView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, ImageScrollViewDelegate {
        var parent: ImageScrollViewWrapper
        var cancellables = Set<AnyCancellable>()
        var didPan = false
        
        init(_ parent: ImageScrollViewWrapper) {
            self.parent = parent
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            withAnimation {
                parent.scale.wrappedValue = scrollView.zoomScale / scrollView.minimumZoomScale
            }
        }
        
        @objc func panGestureDidPan() {
            didPan = true
        }
        
        func imageScrollViewDidChangeOrientation(imageScrollView: ImageScrollView) {
            
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            parent.didEndDragging()
        }
        
        func imageScrollViewDidIndicateDismiss() {
            if parent.selfDismiss {
                parent.dismissSelf()
            }
            parent.presented.wrappedValue = false
        }
        
        @objc func onLongPresss() {
            parent.showActionSheet.wrappedValue = true
        }
    }
    
}
