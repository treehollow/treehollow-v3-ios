//
//  HollowImage.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/17.
//  Copyright © 2021 treehollow. All rights reserved.
//

import UIKit

/// Image wrapper for displaying in a hollow with support for placeholder.
struct HollowImage {
    /// Width and hight information to display a placeholder.
    var placeholder: (width: CGFloat, height: CGFloat)
    /// The image to display.
    var image: UIImage?
    /// image url
    var imageURL: String?
    
    /// - parameter placeholder: Placeholder metadata.
    /// - parameter image: The image to display, set it to `nil` when the image is still loading.
    init(placeholder: (width: CGFloat, height: CGFloat), image: UIImage?, imageURL: String?) {
        self.placeholder = placeholder
        self.image = image
        self.imageURL = imageURL
    }
    
    /// Set the actual image to display.
    /// - parameter image: The image to display.
    ///
    /// Call it right after the image has been fetched.
    mutating func setImage(_ image: UIImage) {
        self.image = image
    }
    
    /// setImageURL
    /// - Parameter imageURL: imageurl for image
    mutating func setImageURL(_ imageURL: String) {
        self.imageURL = imageURL
    }
}
