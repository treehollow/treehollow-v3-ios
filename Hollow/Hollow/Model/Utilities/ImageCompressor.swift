//
//  ImageCompressor.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/13.
//  Copyright © 2021 treehollow. All rights reserved.
//

import UIKit

struct ImageCompressor {
    var dataCountThreshold: Int
    var image: UIImage
    func compress() -> (Data, String)? {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB]
        formatter.countStyle = .file
        
        if let jpegData = image.jpegData(compressionQuality: 1),
           jpegData.base64EncodedData().count <= dataCountThreshold {
            return (jpegData, formatter.sizeDescription(forData: jpegData)!)
        }
        
        let maxQuality: CGFloat = 0.9
        
        for i in 1...5 {
            // Quality
            let quality = maxQuality / CGFloat(i)
            if let data = compress(image, quality: quality) {
                return (data, formatter.sizeDescription(forData: data)!)
            }
            
            // Size
            let resizeFactor = maxQuality * pow(0.7, CGFloat(i))
            if let jpegData = image.resizeTo(scaleFactor: resizeFactor).jpegData(compressionQuality: 1) {
                let base64Data = jpegData.base64EncodedData()
                if base64Data.count <= dataCountThreshold {
                    print("[ImageCompressor] Succeed to compress with resizing factor \(resizeFactor), the size is \(base64Data.count)")
                    return (jpegData, formatter.sizeDescription(forData: jpegData)!)
                } else {
                    print("[ImageCompressor] Fail to compress with resizing factor \(resizeFactor), the size is \(base64Data.count)")
                }
            }

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
