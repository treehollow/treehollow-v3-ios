//
//  HollowImage.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/17.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Cache

/// Image wrapper for displaying in a hollow with support for placeholder.
struct HollowImage: Codable{
    
    struct ImagePlaceHolder: Codable {
        var width: CGFloat
        var height: CGFloat
    }
    /// Width and hight information to display a placeholder.
    var placeholder: ImagePlaceHolder
    /// The image to display.
    /// store image here
    private var imageWrapper: ImageWrapper?
    /// image url
    var imageURL: String
    
    var loadingError: String?
    
    var image: UIImage? {
        get { imageWrapper?.image }
        set {
            if let image = newValue {
                imageWrapper = ImageWrapper(image: image)
            }
        }
    }
    
    /// - parameter placeholder: Placeholder metadata.
    /// - parameter image: The image to display, set it to `nil` when the image is still loading.
    init(placeholder: (width: CGFloat, height: CGFloat), image: UIImage?, imageURL: String) {
        self.placeholder = ImagePlaceHolder(
            width: placeholder.width,
            height: placeholder.height
        )
        self.imageURL = imageURL
        self.image = image
    }
}
