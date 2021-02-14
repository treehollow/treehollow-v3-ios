//
//  HollowInputStore.swift
//  Hollow
//
//  Created by liang2kls on 2021/2/11.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import Defaults

class HollowInputStore: ObservableObject {
    var presented: Binding<Bool>
    
    @Published var text: String = ""
    // FIXME: Remove this code in real tests
    @Published var image: UIImage?
    @Published var compressedImage: UIImage?
    #if targetEnvironment(simulator)
    @Published var availableTags: [String] = ["性相关", "政治相关", "令人不适"]
    #else
    @Published var availableTags: [String] = Defaults[.hollowConfig]!.sendableTags
    #endif
    @Published var selectedTag: String?
    @Published var voteInformation: VoteInformation?
    @Published var sending = false
    @Published var errorMessage: (title: String, message: String)?
    @Published var imageSizeInformation: String?
    
    init(presented: Binding<Bool>) {
        self.presented = presented
    }
    
    func newVote() {
        self.voteInformation = .init(options: ["", "", ""])
    }
    
    func sendPost() {
        withAnimation { sending = true }
        let request = SendPostRequest(configuration: .init(apiRoot: Defaults[.hollowConfig]!.apiRootUrls, token: Defaults[.accessToken]!, text: text, tag: selectedTag, imageData: compressedImage?.jpegData(compressionQuality: 1), voteData: voteInformation?.options))
        
        request.performRequest(completion: { result, error in
            DispatchQueue.main.async { withAnimation {
                self.sending = false
                
                if let error = error {
                    self.errorMessage = (title: "Error", message: error.description)
                    return
                }
                
                // TODO: Quit and show detail
                
                self.presented.wrappedValue = false
            }}
            
        })
    }
    
    func compressImage() {
        guard let image = image else { return }
        withAnimation { compressedImage = nil }
        DispatchQueue.global(qos: .background).async {
            guard let result = ImageCompressor(dataCountThreshold: 512 * 1024, image: image).compress() else {
                DispatchQueue.main.async { withAnimation {
                    self.image = nil
                    self.errorMessage = (title: "Image Too Large", message: "The image cannot be compressed. Please select another image.")
                }}
                return
            }
            DispatchQueue.main.async { withAnimation {
                self.image = nil
                self.compressedImage = UIImage(data: result.0)
                self.imageSizeInformation = result.1
            }}
        }
    }
}

extension HollowInputStore {
    struct VoteInformation {
        var options: [String]
        var hasDuplicate: Bool {
            var optionsWithoutEmptyString = options
            optionsWithoutEmptyString.removeAll(where: { $0 == "" })
            return Set(optionsWithoutEmptyString).count != optionsWithoutEmptyString.count
        }
        var valid: Bool {
            for option in options {
                if option == "" { return false }
            }
            return !hasDuplicate
        }
        
        func optionHasDuplicate(_ text: String) -> Bool {
            guard text != "" else { return false }
            var count: Int = 0
            for option in options {
                if text == option { count += 1}
            }
            return count > 1
        }
    }
}
