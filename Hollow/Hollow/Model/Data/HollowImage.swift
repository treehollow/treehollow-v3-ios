//
//  HollowImage.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/17.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import UIKit
import Cache

/// Image wrapper for displaying in a hollow with support for placeholder.
struct HollowImage: Codable{
    
    struct ImagePlaceHolderType: Codable {
        var width: CGFloat
        var height: CGFloat
    }
    /// Width and hight information to display a placeholder.
    var placeholder: ImagePlaceHolderType
    /// The image to display.
    var image: UIImage? {
        get {
            return self.imageWrapper?.image
        }
        set(image) {
            if let image = image {
                self.imageWrapper = ImageWrapper(image: image)
            }
        }
    }
    /// store image here
    var imageWrapper: ImageWrapper?
    /// image url
    var imageURL: String?
    
    /// - parameter placeholder: Placeholder metadata.
    /// - parameter image: The image to display, set it to `nil` when the image is still loading.
    init(placeholder: (width: CGFloat, height: CGFloat), image: UIImage?, imageURL: String?) {
        self.placeholder = ImagePlaceHolderType(
            width: placeholder.width,
            height: placeholder.height
        )
        self.imageURL = imageURL
        self.image = image
    }
    
}
