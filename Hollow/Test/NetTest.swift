//
//  NetTest.swift
//  Hollow
//
//  Created by aliceinhollow on 1/2/2021.
//  Copyright © 2021 treehollow. All rights reserved.
//

#if DEBUG

import Foundation

struct NetTest {
    var config: HollowConfig?
    init() {
        // GetConfigRequestConfiguration
        GetConfigRequest(configuration: GetConfigRequestConfiguration(hollowType: .thu, customAPIRoot: nil)!).performRequest { result, error in
            debugPrint(result ?? "GetConfigRequest no result")
            debugPrint(error ?? "GetConfigRequest no error")
            //EmailCheck
            EmailCheckRequest(configuration: EmailCheckRequestConfiguration(email: "testabc@tsinghua.edu.cn", reCAPTCHAInfo: (token: "?", version: EmailCheckRequestConfiguration.ReCAPTCHAVersion.v2), hollowConfig: result!)).performRequest{result, error in
                debugPrint(result ?? "EmailCheckRequest no result")
                debugPrint(error ?? "EmailCheckRequest no error")
                
            }
            
        }
    }
}

#endif
