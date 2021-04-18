//
//  HollowImageView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/22.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

struct HollowImageView: View {
    var hollowImage: HollowImage?
    var description: String?
    @State private var flash = false
    @State private var showSavePhotoAlert = false
    @State private var savePhotoError: String? = nil
    @State private var showImageViewer = false
    @State private var showFileExporter = false
    
    /// Handler to reload the current image if error occurs.
    ///
    /// As the image view does not manage the data source, it is more appropirate
    /// to handle the request outside the view. The handler is responsible for
    /// removing the error message before reload action.
    var reloadImage: ((HollowImage) -> Void)? = nil
    
    var minRatio: CGFloat = 0
    private var imageAspectRatio: CGFloat {
        guard let image = hollowImage else { return 1 }
        return image.placeholder.width / image.placeholder.height
    }
    private var aspectRatio: CGFloat {
        return max(imageAspectRatio, minRatio)
    }
    
    @ScaledMetric private var reloadButtonSize: CGFloat = 50
    
    var body: some View {
        Group {
            if let hollowImage = self.hollowImage {
                if let image = hollowImage.image {
                    Group {
                        if imageAspectRatio >= aspectRatio - 0.001 {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .imageSaver(image: image, showSavePhotoAlert: $showSavePhotoAlert, savePhotoError: $savePhotoError)
                        } else {
                            ZStack {
                                Image(uiImage: image)
                                    .resizable()
                                Blur().ignoresSafeArea()
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .imageSaver(image: image, showSavePhotoAlert: $showSavePhotoAlert, savePhotoError: $savePhotoError)
                            }
                            .compositingGroup()
                            .aspectRatio(aspectRatio, contentMode: .fill)
                        }
                    }
                    
                    .animation(.default)
                    .contentShape(RoundedRectangle(cornerRadius: 4))
                    .onChange(of: showSavePhotoAlert) { show in
                        if show {
                            if let error = savePhotoError {
                                showErrorToast(
                                    title: nil,
                                    message: error.description +
                                        NSLocalizedString("IMAGEVIEW_SAVE_IMAGE_FAIL_ALERT_NOTE", comment: ""))
                                savePhotoError = nil
                            } else {
                                showSuccessToast(
                                    title: nil,
                                    message: NSLocalizedString("IMAGEVIEW_SAVE_IMAGE_SUCCESS_ALERT_TITLE", comment: "")
                                )
                            }
                            showSavePhotoAlert = false
                        }
                    }
                    .onClickGesture(lightEffect: false) {
                        IntegrationUtilities.presentView(presentationStyle: .overFullScreen, transitionStyle: .crossDissolve, content: {
                            ImageViewer(image: image, footnote: description, presented: $showImageViewer, selfDismiss: true)
                        })
                    }
                } else {
                    Rectangle()
                        .foregroundColor(.uiColor(flash ? .systemFill : .tertiarySystemFill))
                        .aspectRatio(aspectRatio, contentMode: .fit)
                        .overlay(Group { if let _ = self.hollowImage?.loadingError {
                            Button(action: {
                                reloadImage?(self.hollowImage!)
                            }) {
                                ZStack {
                                    Color.hollowContentVoteGradient1
                                    Image(systemName: "arrow.clockwise")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding()
                                        .font(.system(size: reloadButtonSize, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .revertColorScheme()
                                .frame(maxWidth: reloadButtonSize * 1.5, maxHeight: reloadButtonSize * 1.5)
                                .clipShape(Circle())
                                .padding()
                            }
                        }})
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
