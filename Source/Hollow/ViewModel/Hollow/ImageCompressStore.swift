//
//  InputStore.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/17.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import SwiftUI

/// Protocol for stores which handle image compression.
protocol ImageCompressStore: class {
    var image: UIImage? { get set }
    var compressedImage: UIImage? { get set }
    var compressedImageBase64String: String? { get set }
    var errorMessage: (title: String, message: String)? { get set }
    var imageSizeInformation: String? { get set }
    var cancelledImages: [UIImage] { get set }
}

extension ImageCompressStore {
    func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard providers.count == 1 else { return false }
        if let _ = providers.first?.loadObject(ofClass: UIImage.self, completionHandler: { image, error in
            guard let image = image else { return }
            DispatchQueue.main.async {
                withAnimation {
                    self.cancel()
                    self.image = image as? UIImage
                }
            }
        }) {
            return true
        }
        return false
    }
    
    private func cancel() {
        if let image = self.image {
            // To be checked when current compression
            // is done.
            self.cancelledImages.append(image)
            self.image = nil
        }
        self.compressedImage = nil
        self.compressedImageBase64String = nil
        self.imageSizeInformation = nil
    }
    
    func compressImage() {
        guard let image = image else { return }
        withAnimation { compressedImage = nil }
        DispatchQueue.global(qos: .background).async {
            let compressor = ImageCompressor(dataCountThreshold: 600 * 1024, image: image)
            guard let result = compressor.compress() else {
                DispatchQueue.main.async { withAnimation {
                    self.image = nil
                    self.errorMessage = (
                        title: NSLocalizedString("IMAGE_COMPRESSOR_IMAGE_TOO_LARGE", comment: ""),
                        message: NSLocalizedString("IMAGE_COMPRESSOR_IMAGE_TOO_LARGE_DESCRIPTION", comment: "")
                    )
                }}
                return
            }
            DispatchQueue.main.async { withAnimation {
                for cancelledImageIndex in self.cancelledImages.indices {
                    if self.cancelledImages[cancelledImageIndex].isEqual(image) {
                        self.cancelledImages.remove(at: cancelledImageIndex)
                        return
                    }
                }
                self.image = nil
                self.compressedImage = UIImage(data: result.jpegData)
                self.imageSizeInformation = result.description
                self.compressedImageBase64String = result.base64String
            }}
        }
    }
}
