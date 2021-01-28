//
//  Search.swift
//  Hollow
//
//  Created by liang2kl on 2021/1/28.
//  Copyright © 2021 treehollow. All rights reserved.
//

import Combine
import Foundation

class Search: ObservableObject {
    @Published var searchText: String = ""
    @Published var startDate: Date = .init()
    @Published var endDate: Date = .init()
    @Published var selectsPartialSearch = false
}
