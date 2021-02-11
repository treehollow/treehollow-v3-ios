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
    
    var body: some View {
        Group {
            if let hollowImage = self.hollowImage {
                if let image = hollowImage.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .animation(.default)
                        .contentShape(RoundedRectangle(cornerRadius: 4))
                        .contextMenu(ContextMenu(menuItems: {
                            Button(action:{
                                ImageSaver(finishHandler: { error in
                                    showSavePhotoAlert = true
                                    savePhotoError = error?.localizedDescription
                                }).writeToPhotoAlbum(image: image)
                            }) {
                                Label(LocalizedStringKey("Save to Photos"), systemImage: "square.and.arrow.down")
                            }
                        }))
                        .alert(isPresented: $showSavePhotoAlert, content: {
                            return Alert(title: Text(savePhotoError?.description ?? NSLocalizedString("Successfully saved to Photos.", comment: "")))
                        })
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

#if DEBUG
struct HollowImageView_Previews: PreviewProvider {
    static var previews: some View {
        HollowImageView(hollowImage: .init(placeholder: (1760, 1152), image: UIImage(named: "test")))
    }
}
#endif
