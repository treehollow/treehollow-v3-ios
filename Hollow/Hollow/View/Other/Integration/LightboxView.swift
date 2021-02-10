//
//  LightboxView.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/10.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI
import Lightbox

struct LightboxView: UIViewControllerRepresentable {
    var image: UIImage
    var footnote: String?
    func makeUIViewController(context: Context) -> LightboxController {
        let lightboxVC = LightboxController(images: [.init(image: image, text: footnote ?? "")])
        lightboxVC.dynamicBackground = true
        return lightboxVC
    }
    
    func updateUIViewController(_ uiViewController: LightboxController, context: Context) {
        
    }
}
