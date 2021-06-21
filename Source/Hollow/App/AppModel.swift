//
//  AppModel.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/15.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Combine
import Defaults
import SwiftUI

class AppModel: ObservableObject {
    static let shared = AppModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isInMainView = Defaults[.accessToken] != nil && Defaults[.hollowConfig] != nil
    var widgetReloadCount = 0
    
    private init() {
        // Chcek for version update
        _UpdateAvailabilityRequest.defaultPublisher
            .sinkOnMainThread(receiveValue: VersionUpdateUtilities.handleUpdateAvailabilityResult)
            .store(in: &cancellables)
    }
    
    func handleURL(_ url: URL, with openURL: OpenURLAction) {
        var urlString = url.absoluteString
        if urlString.prefix(15) == "HollowWidget://" || urlString.prefix(15) == "Hollow://post-#" {
            urlString.removeSubrange(urlString.range(of: urlString.prefix(15))!)
            if let postId = Int(urlString) {
                IntegrationUtilities.openTemplateDetailView(postId: postId)
            }
        } else if urlString.prefix(13) == "Hollow://url-" {
            urlString.removeSubrange(urlString.range(of: urlString.prefix(13))!)
            if let url = URL(string: urlString) {
                try? OpenURLHelper(openURL: openURL).tryOpen(url, method: Defaults[.openURLMethod])
            }
        }
    }
}
