//
//  View+hideKeyboard.swift
//  Hollow
//
//  Created by liang2kl on 2021/2/16.
//  Copyright © 2021 treehollow. All rights reserved.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
