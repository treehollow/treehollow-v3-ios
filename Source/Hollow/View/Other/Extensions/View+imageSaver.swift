//
//  View+imageSaver.swift
//  Hollow
//
//  Created by liang2kl on 2021/4/15.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

fileprivate let saveButtonLabel = UIDevice.isMac ?
    NSLocalizedString("IMAGEVIEW_SAVE_PHOTO_BUTTON_MAC", comment: "") :
    NSLocalizedString("IMAGEVIEW_SAVE_PHOTO_BUTTON", comment: "")

extension View {
    func imageSaver(image: UIImage, showSavePhotoAlert: Binding<Bool>, savePhotoError: Binding<String?>) -> some View {
        return self.modifier(ImageSaverModifier(image: image, showSavePhotoAlert: showSavePhotoAlert, savePhotoError: savePhotoError))
    }
}

fileprivate struct ImageSaverModifier: ViewModifier {
    let image: UIImage
    @Binding var showSavePhotoAlert: Bool
    @Binding var savePhotoError: String?
    
    @State private var exporterPresented = false
    
    @ViewBuilder func body(content: Content) -> some View {
        #if targetEnvironment(macCatalyst)
        content
            .fileExporter(isPresented: $exporterPresented, document: ImageFileDocument(image), contentType: .png, onCompletion: { result in
                var errorDescription: String?
                switch result {
                case .failure(let error): errorDescription = error.localizedDescription
                default: break
                }
                showSavePhotoAlert = true
                savePhotoError = errorDescription
            })

            .contextMenu(menuItems: {
                Button(action:{
                    exporterPresented = true
                }) {
                    Label(saveButtonLabel, systemImage: "square.and.arrow.down")
                }
            })
        #else
        content
            .contextMenu(menuItems: {
                Button(action:{
                    ImageSaver(finishHandler: { error in
                        showSavePhotoAlert = true
                        savePhotoError = error?.localizedDescription
                    }).saveImage(image)
                }) {
                    Label(saveButtonLabel, systemImage: "square.and.arrow.down")
                }
            })
        #endif
    }
}

fileprivate struct ImageFileDocument: FileDocument {
    static var readableContentTypes: [UTType] = [.png]
    
    var image: UIImage?
    
    init(_ image: UIImage) {
        self.image = image
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            image = UIImage(data: data)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = image?.pngData() else { throw NSError(domain: "image.saver.error", code: 0, userInfo: nil) }
        return FileWrapper(regularFileWithContents: data)
    }
}
