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
    var errorMessage: (title: String, message: String)? { get set }
    var imageSizeInformation: String? { get set }
}

extension ImageCompressStore {
    func compressImage() {
        guard let image = image else { return }
        withAnimation { compressedImage = nil }
        DispatchQueue.global(qos: .background).async {
            let compressor = ImageCompressor(dataCountThreshold: 512 * 1024, image: image)
            guard let result = compressor.compress() else {
                DispatchQueue.main.async { withAnimation {
                    self.image = nil
                    self.errorMessage = (title: "Image Too Large", message: "The image cannot be compressed. Please select another image.")
                }}
                return
            }
            DispatchQueue.main.async { withAnimation {
                self.image = nil
                self.compressedImage = UIImage(data: result.0)
                self.imageSizeInformation = result.1
            }}
        }
    }
}
