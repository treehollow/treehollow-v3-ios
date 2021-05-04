//
//  CrossPlatformImage.swift
//  Hollow
//
//  Created by liang2kl on 2021/4/24.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

#if os(macOS) && !targetEnvironment(macCatalyst)
private extension NSBitmapImageRep {
    var png: Data? { representation(using: .png, properties: [:]) }
}
private extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}
extension NSImage {
    func pngData() -> Data? {
        return tiffRepresentation?.bitmap?.png
    }
    
    func jpegData(compressionQuality: CGFloat) -> Data? {
        let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [.compressionFactor : compressionQuality])
        return jpegData
    }
    
}

extension Image {
    init(uiImage: NSImage) {
        self.init(nsImage: uiImage)
    }
}
#endif
