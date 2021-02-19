//
//  ImageDownloader.swift
//  Hollow
//
//  Created by aliceinhollow on 2/19/21.
//  Copyright © 2021 treehollow. All rights reserved.
// from `https://stackoverflow.com/questions/35204620/get-uiimage-only-with-kingfisher-library`

import UIKit
import Kingfisher

func downloadImage(urlBase: [String], urlString : String, imageCompletionHandler: @escaping (UIImage?) -> Void){
    // TODO: auto switch
    let urlbase = urlBase[0]
    
    guard let url = URL.init(string: urlbase + urlString) else {
        return  imageCompletionHandler(nil)
    }
    let resource = ImageResource(downloadURL: url)
    
    KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
        switch result {
        case .success(let value):
            imageCompletionHandler(value.image)
        case .failure:
            imageCompletionHandler(nil)
        }
    }
}
