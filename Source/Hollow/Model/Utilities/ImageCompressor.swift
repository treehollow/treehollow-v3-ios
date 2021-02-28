//
//  ImageCompressor.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/13.
//  Copyright © 2021 treehollow. All rights reserved.
//

import UIKit

struct ImageCompressor {
    static let resizingQuality: CGFloat = 0.7
    var dataCountThreshold: Int
    var image: UIImage
    func compress() -> (Data, String)? {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB]
        formatter.countStyle = .file
        
        if let jpegData = image.jpegData(compressionQuality: 1),
           jpegData.count <= dataCountThreshold {
            print("[ImageCompressor] Succeed to compress with quality 1, the size is \(jpegData.count)")
            return (jpegData, formatter.sizeDescription(forData: jpegData)!)
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
                return (successData, formatter.sizeDescription(forData: successData)!)
            } else if let finalData = finalData {
                return (finalData, formatter.sizeDescription(forData: finalData)!)
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
            if let jpegData = image.resizeTo(scaleFactor: resizeFactor).jpegData(compressionQuality: ImageCompressor.resizingQuality) {
                let base64Data = jpegData.base64EncodedData()
                if base64Data.count <= dataCountThreshold {
                    print("[ImageCompressor] Succeed to compress with resizing factor \(resizeFactor), the size is \(base64Data.count)")
                    minResizingFactor = (maxResizingFactor + minResizingFactor) / 2
                    finalResizingData = jpegData
                    if i < resizeAttempt { continue }
                    return (jpegData, formatter.sizeDescription(forData: jpegData)!)
                } else {
                    print("[ImageCompressor] Fail to compress with resizing factor \(resizeFactor), the size is \(base64Data.count)")
                }
            }
            
            maxResizingFactor = (maxResizingFactor + minResizingFactor) / 2
        }
        
        if let finalResizingData = finalResizingData {
            let base64Data = finalResizingData.base64EncodedData()
            return (finalResizingData, formatter.sizeDescription(forData: base64Data)!)
        }
        
        return nil
    }
    
    func compress(_ image: UIImage, quality: CGFloat) -> Data? {
        if let jpegData = image.jpegData(compressionQuality: quality) {
            let base64Data = jpegData.base64EncodedData()
            if base64Data.count <= dataCountThreshold {
                print("[ImageCompressor] Succeed to compress with quality \(quality), the size is \(base64Data.count)")
                return jpegData
            } else {
                print("[ImageCompressor] Fail to compress with quality \(quality), the size is \(base64Data.count)")
            }
            
        }
        return nil
    }
}

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

private extension ByteCountFormatter {
    func sizeDescription(forData data: Data) -> String? {
        return self.string(for: data.count)
    }
}
