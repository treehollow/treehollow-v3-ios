//
//  HollowCommentInputStore.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/17.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import SwiftUI

class HollowCommentInputStore: ObservableObject, AppModelEnvironment, ImageCompressStore {
    @Published var appModelState = AppModelState()
    @Published var errorMessage: (title: String, message: String)?
    @Published var imageSizeInformation: String?
    
    @Published var text: String = ""
    @Published var image: UIImage?
    @Published var compressedImage: UIImage?
    
}
