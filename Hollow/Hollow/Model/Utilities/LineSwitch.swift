//
//  LineSwitching.swift
//  Hollow
//
//  Created by aliceinhollow on 2021/2/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Defaults
import SwiftyPing

/// perform auto line switching
struct LineSwitch {
    
    struct apiLatencyBundle: Codable {
        var api: String
        var ping: TimeInterval
    }
    
    /// store api roots in order
    /// `"name" : [apiList]`
    typealias OrderdLineStorage = [String: [apiLatencyBundle]]
    
    /// identify different line type
    enum LineType: String {
        case apiRoot = "apiRoot"
        case imageBaseURL = "imgBaseURL"
    }
    
    /// Select a urlbase for request
    /// - Parameter urlBase: api root list
    /// - Returns: url which should be used
    func LineSelect (urlBase: [String], type: LineType) -> String {
        
        guard let orderdLineStorage = Defaults[.orderdLineStorage],
              let apiList = orderdLineStorage[type.rawValue],
              apiList.map({ $0.api }) == urlBase
        else {
            setAPIList(urlBase: urlBase, type: type)
            testPing(type: type)
            return LineSelect(urlBase: urlBase, type: type)
        }
        return apiList[0].api
    }
    
    /// test all the and sort them in order
    /// - Parameter type: line type, img or api
    /// # TODO: perform test on network change
    func testPing(type: LineType) {
        guard var apiList = Defaults[.orderdLineStorage]?[type.rawValue] else { return }
        
        let testPingGroup = DispatchGroup()
        
        for index in apiList.indices {
            guard let hostname = apiList[index].api.findHost() else { continue }
            testPingGroup.enter()
            
            let once = try? SwiftyPing(host: hostname, configuration: PingConfiguration(interval: 0.5, with: 5), queue: DispatchQueue.global())
            once?.observer = { (response) in
                let duration = response.duration
                // no ping, set to a very large value
                apiList[index].ping = duration ?? TimeInterval(INT_MAX)
                //print(apiList)
                testPingGroup.leave()
            }
            once?.targetCount = 1
            try? once?.startPinging()
        }
        
        testPingGroup.notify(queue: .main) {
            //sort all apis by ping
            apiList.sort { $0.ping < $1.ping }
            //print(apiList)
            Defaults[.orderdLineStorage]?[type.rawValue] = apiList
        }
    }
    
    /// set url base directly
    /// - Parameters:
    ///   - urlBase: url base list
    ///   - type: line type
    func setAPIList(urlBase: [String], type: LineType) {
        let apiList = urlBase.map{apiLatencyBundle(api: $0, ping: TimeInterval(INT_MAX))}
        // get an old one or summon a new one
        var orderdLineStorage = Defaults[.orderdLineStorage] ?? OrderdLineStorage()
        orderdLineStorage[type.rawValue] = apiList
        Defaults[.orderdLineStorage] = orderdLineStorage
    }
    
    func testAll() {
        testPing(type: .apiRoot)
        testPing(type: .imageBaseURL)
    }
}
