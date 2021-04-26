//
//  ImageCompressor.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/13.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

struct ImageCompressor {
    static let resizingQuality: CGFloat = 0.7
    var dataCountThreshold: Int
    var image: HImage
    func compress() -> (jpegData: Data, base64String: String, description: String)? {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB]
        formatter.countStyle = .file
        
        if let pngData = image.pngData(),
           pngData.count <= dataCountThreshold {
            print("[ImageCompressor] Succeed to compress with quality 1, the size is \(pngData.count)")
            return (pngData, pngData.base64EncodedString(), formatter.sizeDescription(forData: pngData)!)
        }
        
        // Quality
        var maxQuality: CGFloat = 1.3
        var minQuality: CGFloat = 0.1
        
        var finalData: Data?
        
        let qualityAttempt = 3
        for i in 1...qualityAttempt {
            let quality = (maxQuality + minQuality) / 2
            let data = compress(image, quality: quality)
            if let successData = data {
                minQuality = (maxQuality + minQuality) / 2
                finalData = successData
                if i < qualityAttempt { continue }
                return (successData, successData.base64EncodedString(), formatter.sizeDescription(forData: successData)!)
            } else if let finalData = finalData {
                return (finalData, finalData.base64EncodedString(), formatter.sizeDescription(forData: finalData)!)
            }
            
            maxQuality = (maxQuality + minQuality) / 2
        }
            
        // Size
        var maxResizingFactor: CGFloat = 1.5
        var minResizingFactor: CGFloat = 0.1
        
        var finalResizingData: Data?
        
        let resizeAttempt = 6
        for i in 1...resizeAttempt {
            let resizeFactor = (maxResizingFactor + minResizingFactor) / 2
            if let jpegData = image.resizeTo(scaleFactor: resizeFactor).pngData() {
                if jpegData.count <= dataCountThreshold {
                    print("[ImageCompressor] Succeed to compress with resizing factor \(resizeFactor), the size is \(jpegData.count)")
                    minResizingFactor = (maxResizingFactor + minResizingFactor) / 2
                    finalResizingData = jpegData
                    if i < resizeAttempt { continue }
                    return (jpegData, jpegData.base64EncodedString(), formatter.sizeDescription(forData: jpegData)!)
                } else {
                    print("[ImageCompressor] Fail to compress with resizing factor \(resizeFactor), the size is \(jpegData.count)")
                }
            }
            
            maxResizingFactor = (maxResizingFactor + minResizingFactor) / 2
        }
        
        if let finalResizingData = finalResizingData {
            let base64String = finalResizingData.base64EncodedString()
            return (finalResizingData, base64String, formatter.sizeDescription(forData: finalResizingData)!)
        }
        
        return nil
    }
    
    func compress(_ image: HImage, quality: CGFloat) -> Data? {
        if let jpegData = image.jpegData(compressionQuality: quality) {
            if jpegData.count <= dataCountThreshold {
                print("[ImageCompressor] Succeed to compress with quality \(quality), the size is \(jpegData.count)")
                return jpegData
            } else {
                print("[ImageCompressor] Fail to compress with quality \(quality), the size is \(jpegData.count)")
            }
            
        }
        return nil
    }
}

#if !os(macOS)
private extension UIImage {
    func resizeTo(scaleFactor: CGFloat) -> UIImage {
        let destinationSize = CGSize(width: self.size.width * scaleFactor, height: self.size.height * scaleFactor)
        
        UIGraphicsBeginImageContext(destinationSize)
        draw(in: CGRect.init(origin: CGPoint(x: 0, y: 0), size: destinationSize))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image ?? self
    }

}
#else
private extension NSImage {
    func resizeTo(scaleFactor: CGFloat) -> NSImage {
        let destSize = CGSize(width: self.size.width * scaleFactor, height: self.size.height * scaleFactor)
        let newImage = NSImage(size: destSize)
        newImage.lockFocus()
        self.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSMakeRect(0, 0, self.size.width, self.size.height), operation: .sourceOver, fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = destSize
        return NSImage(data: newImage.tiffRepresentation!)!
    }
}
#endif

private extension ByteCountFormatter {
    func sizeDescription(forData data: Data) -> String? {
        return self.string(for: data.count)
    }
}
