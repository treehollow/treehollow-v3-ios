//
//  NetTest.swift
//  Hollow
//
//  Created by aliceinhollow on 1/2/2021.
//  Copyright © 2021 treehollow. All rights reserved.
//

#if DEBUG

import Foundation
import Defaults

struct NetTest {
    init() {
         SHA256
        let testSHA256 = "abcde"
        let testEmail = "testabc@tsinghua.edu.cn"
        let testToken = "ee2uyrsj5xg4i5uywn7qhin6o3zzat6"
        debugPrint(testSHA256.sha256().sha256())
        // GetConfigRequestConfiguration
        GetConfigRequest(configuration: GetConfigRequestConfiguration(hollowType: .thu, customAPIRoot: nil)!).performRequest { result, error in
            debugPrint(result ?? "GetConfigRequest no result")
            debugPrint(error ?? "GetConfigRequest no error")
            //EmailCheck
            EmailCheckRequest(configuration: EmailCheckRequestConfiguration(email: testEmail, reCAPTCHAInfo: (token: "?", version: EmailCheckRequestConfiguration.ReCAPTCHAVersion.v2), apiRoot: result!.apiRoot)).performRequest{result, error in
                debugPrint(result ?? "EmailCheckRequest no result")
                debugPrint(error ?? "EmailCheckRequest no error")
            }
            //Device List
            DeviceListRequest(configuration: DeviceListRequestConfiguration(token: testToken, apiRoot: result!.apiRoot)).performRequest{result, error in
                debugPrint(result ?? "EmailCheckRequest no result")
                debugPrint(error ?? "EmailCheckRequest no error")
            }
        }
    }
}

#endif
