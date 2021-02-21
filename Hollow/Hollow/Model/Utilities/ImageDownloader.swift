//
//  ImageDownloader.swift
//  Hollow
//
//  Created by aliceinhollow on 2/19/21.
//  Copyright © 2021 treehollow. All rights reserved.
//  from `https://stackoverflow.com/questions/35204620/get-uiimage-only-with-kingfisher-library`

import UIKit
import Kingfisher

struct ImageDownloader {
    static func downloadImage(urlBase: [String], urlString : String, imageCompletionHandler: @escaping (UIImage?) -> Void) {
        // TODO: auto switch
        let urlbase = urlBase[0]
        
        guard let url = URL(string: urlbase + urlString) else {
            imageCompletionHandler(nil)
            return
        }
        
        // use only urlPath as cachekey
        let resource = ImageResource(downloadURL: url, cacheKey: urlString)
        
        KingfisherManager.shared.retrieveImage(with: resource, options: [.memoryCacheExpiration(.never)]) { result in
            switch result {
            case .success(let value):
                imageCompletionHandler(value.image)
            case .failure:
                imageCompletionHandler(nil)
            }
        }
    }
}
