//
//  LineSwitching.swift
//  Hollow
//
//  Created by aliceinhollow on 2021/2/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation
import Defaults
import Alamofire

/// perform auto line switching
struct LineSwitch {
    
    struct apiLatencyBundle: Codable {
        var api: String
        var ping: UInt64
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
    func testPing(type: LineType) {
        guard var apiList = Defaults[.orderdLineStorage]?[type.rawValue] else { return }
        
        let testPingGroup = DispatchGroup()
        var time = [Int: UInt64]()
        
        for index in apiList.indices {
            testPingGroup.enter()
            time[index] = DispatchTime.now().uptimeNanoseconds
            
            AF.request(
                apiList[index].api + Constants.URLConstant.apiTestPath,
                method: .get
            ).validate(statusCode: 204..<204).response { response in
                let endtime = DispatchTime.now().uptimeNanoseconds
                apiList[index].ping = endtime - (time[index] ?? 0)
                testPingGroup.leave()
            }
        }
        
        testPingGroup.notify(queue: .main) {
            //sort all apis by ping
            apiList.sort { $0.ping < $1.ping }
            Defaults[.orderdLineStorage]?[type.rawValue] = apiList
        }
    }
    
    /// set url base directly
    /// - Parameters:
    ///   - urlBase: url base list
    ///   - type: line type
    func setAPIList(urlBase: [String], type: LineType) {
        let apiList = urlBase.map{apiLatencyBundle(api: $0, ping: UINT64_MAX)}
        // get an old one or summon a new one
        var orderdLineStorage = Defaults[.orderdLineStorage] ?? OrderdLineStorage()
        orderdLineStorage[type.rawValue] = apiList
        Defaults[.orderdLineStorage] = orderdLineStorage
    }
    
    /// test all api roots, including api and img
    func testAll() {
        testPing(type: .apiRoot)
        testPing(type: .imageBaseURL)
    }
}
