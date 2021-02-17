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

class HollowInputStore: ObservableObject, AppModelEnvironment, ImageCompressStore {
    var presented: Binding<Bool>
    
    @Published var text: String = ""
    // FIXME: Remove this code in real tests
    @Published var image: UIImage?
    @Published var compressedImage: UIImage?
    @Published var availableTags: [String] = Defaults[.hollowConfig]!.sendableTags
    @Published var selectedTag: String?
    @Published var voteInformation: VoteInformation?
    @Published var sending = false
    @Published var errorMessage: (title: String, message: String)?
    @Published var imageSizeInformation: String?
    @Published var appModelState = AppModelState()
    
    init(presented: Binding<Bool>) {
        self.presented = presented
    }
    
    func newVote() {
        self.voteInformation = .init(options: ["", "", ""])
    }
    
    func sendPost() {
        withAnimation { sending = true }
        let request = SendPostRequest(configuration: .init(apiRoot: Defaults[.hollowConfig]!.apiRootUrls, token: Defaults[.accessToken]!, text: text, tag: selectedTag, imageData: compressedImage?.jpegData(compressionQuality: ImageCompressor.resizingQuality), voteData: voteInformation?.options))
        request.performRequest(completion: { result, error in
            DispatchQueue.main.async { withAnimation {
                self.sending = false
                
                if let error = error {
                    if self.handleTokenExpireError(error) { return }
                    self.errorMessage = (title: "Error", message: error.description)
                    return
                }
                
                // TODO: Quit and show detail
                
                self.presented.wrappedValue = false
            }}
            
        })
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
                if text == option { count += 1 }
            }
            return count > 1
        }
    }
}
