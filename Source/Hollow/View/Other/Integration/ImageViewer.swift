//
//  ImageViewer.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/11.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
//import ImageScrollView
import Combine

struct ImageViewer: View {
    var image: UIImage
    var footnote: String?
    
    @Binding var presented: Bool
    @State private var lineLimit: Int? = 1
    @State private var scale: CGFloat = 0
    @State private var showActionSheet = false
    @State private var savePhotoMessage: (title: String, message: String)?
    @State private var dragRelativeOffset: CGFloat = 0
    @State private var isDragging = false
    
    @State private var shouldDismiss = false
    
    @State private var safeAreaInsets = EdgeInsets()
    
    @Environment(\.colorScheme) var colorScheme
    
    var selfDismiss = false
    
    private let dismissScaleThreshold: CGFloat = UIDevice.isPad ? (UIDevice.isMac ? 0.04 : 0.08) : 0.12
    
    var body: some View {
        ZStack {
            ImageScrollViewWrapper(image: image, presented: $presented, scale: $scale, showActionSheet: $showActionSheet, dragRelativeOffset: $dragRelativeOffset, isDragging: $isDragging, selfDismiss: selfDismiss, didEndDragging: {
                if shouldDismiss { dismiss() }
            })
//            .ignoresSafeArea()
            VStack(spacing: 0) {
                #if targetEnvironment(macCatalyst)
                Button(action: dismiss) {
                    Text("IMAGEVIEWER_DONE_BUTTON")
                        .dynamicFont(size: 16, weight: .semibold)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 6)
                        .blurBackground()
                        .roundedCorner(8)
                }
                .padding(.horizontal)
                .trailing()
                #endif
                
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
                        .onClickGesture { withAnimation {
                            lineLimit = lineLimit == nil ? 1 : nil
                        }}
                }
                
            }
            
            // Hide the components when overlapping
            .opacity(scale > 2 ? 0 : 1)
        }
        
        .modifier(GetSafeAreaInsets(insets: $safeAreaInsets))
        
        .background(
            Color.black
                .ignoresSafeArea()
                .opacity(max(1 - Double(dragRelativeOffset) * (UIDevice.isPad ? (UIDevice.isMac ? 6 : 3) : 2), 0))
        )
        
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
            if offset > dismissScaleThreshold && isDragging {
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
    var isDragging: Binding<Bool>
    var selfDismiss: Bool
    var didEndDragging: () -> Void
    
    func makeUIView(context: Context) -> ImageScrollView {
        let view = ImageScrollView()
        view.setup()
        view.display(image: image)
        view.maxScaleFromMinScale = 4
        view.imageScrollViewDelegate = context.coordinator
        view.imageContentMode = .aspectFit
        view.alwaysBounceVertical = true
        view.alwaysBounceHorizontal = true
        view.addGestureRecognizer(
            UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.onLongPresss))
        )
        
        // To filter out the initial values
        view.panGestureRecognizer.addTarget(context.coordinator, action: #selector(context.coordinator.panGestureDidPan))
        
        view.publisher(for: \.contentOffset)
            .dropFirst()
            .sink(receiveValue: { _ in
                self.isDragging.wrappedValue = view.isDragging
                guard !view.isZooming && context.coordinator.didPan else { return }
                updateOffset(view: view)
            })
            .store(in: &context.coordinator.cancellables)
        
        return view
    }
    
    func updateUIView(_ uiView: ImageScrollView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func updateOffset(view: UIScrollView) {
        let contentOffset = view.contentOffset
        let contentSize = view.contentSize
        let contentInset = view.adjustedContentInset
        let frameSize = view.frame.size
        
        let horizontalOriginalOffset = max(frameSize.width - contentSize.width, 0)
        
        let leftTranslation = contentInset.left - contentOffset.x
        let rightTranslation = contentOffset.x + frameSize.width - contentInset.right - contentSize.width - horizontalOriginalOffset
        let topTranslation = -contentOffset.y - contentInset.top
//        var bottomTranslation = contentOffset.y + frameSize.height - contentInset.bottom - contentSize.height
        
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        if leftTranslation > 0 {
            xOffset = leftTranslation / frameSize.width
        }
        
        if rightTranslation > 0 {
            xOffset = max(xOffset, rightTranslation / frameSize.width)
        }
        
//        if contentSize.height < frameSize.height {
//            bottomTranslation -= (frameSize.height - contentSize.height)
//        }
        
        if topTranslation > 0 {
            yOffset = topTranslation / frameSize.width
        }
        
//        if bottomTranslation > 0 {
//            yOffset = max(yOffset, bottomTranslation / frameSize.width)
//        }

        yOffset = min(1, yOffset)

        DispatchQueue.main.async {
            // Higher resistance for horizontal scroll
            dragRelativeOffset.wrappedValue = sqrt(xOffset * xOffset / 3 + yOffset * yOffset)
        }
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
        
        func imageScrollViewDidChangeOrientation(imageScrollView: ImageScrollView) -> Bool {
            return UIDevice.isPad
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
