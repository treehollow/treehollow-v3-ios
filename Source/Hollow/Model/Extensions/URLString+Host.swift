//
//  URLString+Host.swift
//  Hollow
//
//  Created by aliceinhollow on 2021/2/25.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Foundation

extension String {
    func findHost() -> String? {
        let url = URL(string: self)
        return url?.host
    }
}
