//
//  HollowImageView.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/22.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct HollowImageView: View {
    var hollowImage: HollowImage?
    var description: String?
    @State private var flash = false
    @State private var showSavePhotoAlert = false
    @State private var savePhotoError: String? = nil
    @State private var showImageViewer = false
    
    /// Handler to reload the current image if error occurs.
    ///
    /// As the image view does not manage the data source, it is more appropirate
    /// to handle the request outside the view. The handler is responsible for
    /// removing the error message before reload action.
    var reloadImage: ((HollowImage) -> Void)? = nil
    
    @ScaledMetric private var reloadButtonSize: CGFloat = 50
    
    var body: some View {
        Group {
            if let hollowImage = self.hollowImage {
                if let image = hollowImage.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .animation(.default)
                        .contentShape(RoundedRectangle(cornerRadius: 4))
                        .contextMenu(ContextMenu(menuItems: {
                            Button(action:{
                                ImageSaver(finishHandler: { error in
                                    showSavePhotoAlert = true
                                    savePhotoError = error?.localizedDescription
                                }).saveImage(image)
                            }) {
                                Label("IMAGEVIEW_SAVE_PHOTO_BUTTON", systemImage: "square.and.arrow.down")
                            }
                        }))
                        .styledAlert(
                            presented: $showSavePhotoAlert,
                            title: savePhotoError?.description ?? NSLocalizedString("IMAGEVIEW_SAVE_IMAGE_SUCCESS_ALERT_TITLE", comment: ""),
                            message: nil,
                            buttons: [.ok]
                        )
                        .onTapGesture {
                            showImageViewer = true
                        }
                        .fullScreenCover(isPresented: $showImageViewer, content: {
                            ImageViewer(image: image, footnote: description, presented: $showImageViewer)
                        })
                } else {
                    Rectangle()
                        .foregroundColor(.uiColor(flash ? .systemFill : .tertiarySystemFill))
                        .aspectRatio(hollowImage.placeholder.width / hollowImage.placeholder.height, contentMode: .fit)
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
