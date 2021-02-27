//
//  ImageSaver.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/27.
//  Copyright © 2021 treehollow. All rights reserved.
//

import UIKit

class ImageSaver: NSObject {
    init(finishHandler: @escaping (Error?) -> Void = { _ in }) {
        self.finishHandler = finishHandler
    }
    
    var finishHandler: (Error?) -> Void
    
    func saveImage(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        finishHandler(error)
    }
}
