//
//  VersionUpdateUtilities.swift
//  Hollow
//
//  Created by 梁业升 on 2021/4/27.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Defaults
import SwiftUI

struct VersionUpdateUtilities {
    static func handleUpdateAvailabilityResult(data: UpdateAvailabilityRequest.ResultData?) {
        guard let data = data else {
            Defaults[.versionUpdateInfoCache] = nil
            return
        }
        if !data.0 {
            Defaults[.latestViewedUpdateVersion] = nil
            Defaults[.versionUpdateInfoCache] = nil
            return
        }
        Defaults[.versionUpdateInfoCache] = data.1
        guard Defaults[.latestViewedUpdateVersion] != data.1.version else { return }
        Defaults[.latestViewedUpdateVersion] = data.1.version
        IntegrationUtilities.presentView { NavigationView { VersionUpdateView(info: data.1, showItem: true) }}
    }
}
